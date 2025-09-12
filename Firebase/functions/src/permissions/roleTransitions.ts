/**
 * Role transition functions and workflows for FreshWall permission system
 */

import * as admin from "firebase-admin";
import { onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { 
  UserRole, 
  RoleChangeRequest,
  ROLE_DEFINITIONS,
  getRoleDefinition,
  isHigherRole
} from "./types";
import { 
  validateRoleChangePermission, 
  createAuditLog, 
  getUserWithRole,
  validateTeamMembership,
  PermissionError 
} from "./utils";

interface BulkRoleChangeRequest {
  userIds: string[];
  newRole: UserRole;
  reason?: string;
}

interface RoleChangeWorkflow {
  requestId: string;
  requesterId: string;
  targetUserId: string;
  fromRole: UserRole;
  toRole: UserRole;
  reason?: string;
  status: 'pending' | 'approved' | 'rejected' | 'completed';
  requestedAt: FirebaseFirestore.Timestamp;
  processedAt?: FirebaseFirestore.Timestamp;
  processedBy?: string;
  rejectionReason?: string;
  teamId: string;
}

/**
 * Cloud Function: Request a role change (for future approval workflows)
 */
export const requestRoleChange = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new Error("User must be authenticated");
    }

    const { targetUserId, newRole, reason, teamId } = request.data;
    const requesterId = request.auth.uid;

    if (!targetUserId || !newRole || !teamId) {
      throw new Error("Missing required parameters");
    }

    // Validate the role change permission
    await validateRoleChangePermission(requesterId, targetUserId, teamId, newRole);

    // Get user data
    const requester = await getUserWithRole(requesterId, teamId);
    const target = await getUserWithRole(targetUserId, teamId);

    if (!requester || !target) {
      throw new Error("User not found");
    }

    // For admins, approve immediately. For others, create a workflow
    const isAdminRequest = requester.role === "admin";
    
    const workflowRef = admin.firestore()
      .collection("teams")
      .doc(teamId)
      .collection("roleChangeRequests")
      .doc();

    const workflow: Omit<RoleChangeWorkflow, 'requestId'> = {
      requesterId,
      targetUserId,
      fromRole: target.role,
      toRole: newRole,
      reason,
      status: isAdminRequest ? 'approved' : 'pending',
      requestedAt: admin.firestore.Timestamp.now(),
      teamId
    };

    if (isAdminRequest) {
      // Execute the role change immediately
      workflow.status = 'completed';
      workflow.processedAt = admin.firestore.Timestamp.now();
      workflow.processedBy = requesterId;

      // Update user role
      await admin.firestore()
        .collection("teams")
        .doc(teamId)
        .collection("users")
        .doc(targetUserId)
        .update({
          role: newRole,
          lastModified: admin.firestore.Timestamp.now(),
          modifiedBy: requesterId
        });

      // Create audit log
      await createAuditLog({
        action: 'role_changed',
        actorId: requesterId,
        actorDisplayName: requester.displayName,
        targetUserId,
        targetDisplayName: target.displayName,
        teamId,
        details: {
          fromRole: target.role,
          toRole: newRole,
          reason
        }
      });
    }

    await workflowRef.set(workflow);

    logger.info(`Role change request created: ${workflowRef.id} by ${requesterId} for ${targetUserId}`);

    return {
      requestId: workflowRef.id,
      status: workflow.status,
      message: isAdminRequest ? "Role change completed immediately" : "Role change request submitted for approval"
    };

  } catch (error) {
    if (error instanceof PermissionError) {
      throw new Error(error.message);
    }
    logger.error("Error in requestRoleChange:", error);
    throw new Error("Role change request failed: " + (error instanceof Error ? error.message : "Unknown error"));
  }
});

/**
 * Cloud Function: Bulk role change operation
 */
export const bulkChangeRoles = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new Error("User must be authenticated");
    }

    const { userIds, newRole, reason, teamId }: BulkRoleChangeRequest & { teamId: string } = request.data;
    const requesterId = request.auth.uid;

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0 || !newRole || !teamId) {
      throw new Error("Missing required parameters");
    }

    if (userIds.length > 50) {
      throw new Error("Cannot change roles for more than 50 users at once");
    }

    // Validate requester permissions
    const requester = await validateTeamMembership(requesterId, teamId);

    const results: Array<{
      userId: string;
      displayName: string;
      success: boolean;
      fromRole?: UserRole;
      toRole?: UserRole;
      error?: string;
    }> = [];

    // Process each user
    for (const userId of userIds) {
      try {
        // Validate role change permission for each user
        await validateRoleChangePermission(requesterId, userId, teamId, newRole);
        
        const target = await getUserWithRole(userId, teamId);
        if (!target) {
          results.push({
            userId,
            displayName: "Unknown",
            success: false,
            error: "User not found"
          });
          continue;
        }

        const oldRole = target.role;

        // Skip if already has the target role
        if (oldRole === newRole) {
          results.push({
            userId,
            displayName: target.displayName,
            success: false,
            fromRole: oldRole,
            toRole: newRole,
            error: "User already has this role"
          });
          continue;
        }

        // Perform the role change
        await admin.firestore()
          .collection("teams")
          .doc(teamId)
          .collection("users")
          .doc(userId)
          .update({
            role: newRole,
            lastModified: admin.firestore.Timestamp.now(),
            modifiedBy: requesterId
          });

        // Create audit log
        await createAuditLog({
          action: 'role_changed',
          actorId: requesterId,
          actorDisplayName: requester.displayName,
          targetUserId: userId,
          targetDisplayName: target.displayName,
          teamId,
          details: {
            fromRole: oldRole,
            toRole: newRole,
            reason: reason || `Bulk role change to ${newRole}`
          }
        });

        results.push({
          userId,
          displayName: target.displayName,
          success: true,
          fromRole: oldRole,
          toRole: newRole
        });

      } catch (error) {
        logger.error(`Bulk role change error for user ${userId}:`, error);
        results.push({
          userId,
          displayName: "Unknown",
          success: false,
          error: error instanceof Error ? error.message : "Unknown error"
        });
      }
    }

    const successCount = results.filter(r => r.success).length;
    const errorCount = results.filter(r => !r.success).length;

    logger.info(`Bulk role change completed: ${successCount} successful, ${errorCount} errors`);

    return {
      teamId,
      requesterId,
      newRole,
      totalUsers: userIds.length,
      successCount,
      errorCount,
      results
    };

  } catch (error) {
    if (error instanceof PermissionError) {
      throw new Error(error.message);
    }
    logger.error("Error in bulkChangeRoles:", error);
    throw new Error("Bulk role change failed: " + (error instanceof Error ? error.message : "Unknown error"));
  }
});

/**
 * Cloud Function: Get role change history for a user
 */
export const getUserRoleHistory = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new Error("User must be authenticated");
    }

    const { userId, teamId, limit = 20 } = request.data;
    const requesterId = request.auth.uid;

    if (!teamId) {
      throw new Error("Missing teamId");
    }

    const targetUserId = userId || requesterId;

    // Validate requester can view role history
    const requester = await validateTeamMembership(requesterId, teamId);
    
    // Users can view their own history, admins can view anyone's history
    if (requesterId !== targetUserId && requester.role !== "admin") {
      throw new PermissionError("Insufficient permissions to view role history");
    }

    // Get audit logs related to role changes for this user
    const auditLogsSnapshot = await admin.firestore()
      .collection("teams")
      .doc(teamId)
      .collection("auditLogs")
      .where("targetUserId", "==", targetUserId)
      .where("action", "==", "role_changed")
      .orderBy("timestamp", "desc")
      .limit(limit)
      .get();

    const roleHistory = auditLogsSnapshot.docs.map(doc => {
      const data = doc.data();
      return {
        id: doc.id,
        timestamp: data.timestamp,
        changedBy: {
          id: data.actorId,
          displayName: data.actorDisplayName
        },
        fromRole: data.details.fromRole,
        toRole: data.details.toRole,
        reason: data.details.reason,
        metadata: data.details.metadata
      };
    });

    // Get current user info
    const currentUser = await getUserWithRole(targetUserId, teamId);

    return {
      userId: targetUserId,
      teamId,
      currentRole: currentUser?.role,
      roleHistory,
      hasMore: auditLogsSnapshot.size === limit
    };

  } catch (error) {
    if (error instanceof PermissionError) {
      throw new Error(error.message);
    }
    logger.error("Error in getUserRoleHistory:", error);
    throw new Error("Failed to get role history: " + (error instanceof Error ? error.message : "Unknown error"));
  }
});

/**
 * Cloud Function: Get role change statistics for a team
 */
export const getRoleChangeStats = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new Error("User must be authenticated");
    }

    const { teamId, days = 30 } = request.data;
    const requesterId = request.auth.uid;

    if (!teamId) {
      throw new Error("Missing teamId");
    }

    // Validate requester has admin permissions
    const requester = await validateTeamMembership(requesterId, teamId);
    if (requester.role !== "admin") {
      throw new PermissionError("Only admins can view role change statistics");
    }

    const startDate = admin.firestore.Timestamp.fromMillis(
      Date.now() - (days * 24 * 60 * 60 * 1000)
    );

    // Get role change audit logs
    const auditLogsSnapshot = await admin.firestore()
      .collection("teams")
      .doc(teamId)
      .collection("auditLogs")
      .where("action", "==", "role_changed")
      .where("timestamp", ">=", startDate)
      .orderBy("timestamp", "desc")
      .get();

    const roleChanges = auditLogsSnapshot.docs.map(doc => doc.data());

    // Analyze the data
    const stats = {
      totalRoleChanges: roleChanges.length,
      roleDistribution: {} as Record<string, { from: number; to: number }>,
      topActors: {} as Record<string, { name: string; count: number }>,
      recentChanges: roleChanges.slice(0, 10).map(change => ({
        timestamp: change.timestamp,
        actorName: change.actorDisplayName,
        targetName: change.targetDisplayName,
        fromRole: change.details.fromRole,
        toRole: change.details.toRole,
        reason: change.details.reason
      })),
      timeline: {} as Record<string, number>
    };

    // Process statistics
    roleChanges.forEach(change => {
      const fromRole = change.details.fromRole;
      const toRole = change.details.toRole;
      const actorId = change.actorId;
      const actorName = change.actorDisplayName;

      // Role distribution
      if (!stats.roleDistribution[fromRole]) {
        stats.roleDistribution[fromRole] = { from: 0, to: 0 };
      }
      if (!stats.roleDistribution[toRole]) {
        stats.roleDistribution[toRole] = { from: 0, to: 0 };
      }
      stats.roleDistribution[fromRole].from++;
      stats.roleDistribution[toRole].to++;

      // Top actors
      if (!stats.topActors[actorId]) {
        stats.topActors[actorId] = { name: actorName, count: 0 };
      }
      stats.topActors[actorId].count++;

      // Timeline (by day)
      const date = new Date(change.timestamp.toMillis()).toISOString().split('T')[0];
      stats.timeline[date] = (stats.timeline[date] || 0) + 1;
    });

    return {
      teamId,
      period: { days, startDate: startDate.toMillis() },
      stats
    };

  } catch (error) {
    if (error instanceof PermissionError) {
      throw new Error(error.message);
    }
    logger.error("Error in getRoleChangeStats:", error);
    throw new Error("Failed to get role change statistics: " + (error instanceof Error ? error.message : "Unknown error"));
  }
});

/**
 * Cloud Function: Validate role transition matrix
 */
export const validateRoleTransition = onCall(async (request) => {
  try {
    const { fromRole, toRole, actorRole } = request.data;

    if (!fromRole || !toRole || !actorRole) {
      throw new Error("Missing role parameters");
    }

    const actorRoleDef = getRoleDefinition(actorRole as UserRole);
    const canTransition = 
      actorRole === "admin" || // Admins can do anything
      (actorRoleDef.canDemoteFrom.includes(fromRole) && actorRoleDef.canPromoteTo.includes(toRole));

    const fromRoleDef = getRoleDefinition(fromRole as UserRole);
    const toRoleDef = getRoleDefinition(toRole as UserRole);

    return {
      canTransition,
      reasons: {
        isAdmin: actorRole === "admin",
        canDemoteFrom: actorRoleDef.canDemoteFrom.includes(fromRole),
        canPromoteTo: actorRoleDef.canPromoteTo.includes(toRole),
        levelIncrease: toRoleDef.level > fromRoleDef.level,
        levelDecrease: toRoleDef.level < fromRoleDef.level
      },
      roles: {
        from: { ...fromRoleDef },
        to: { ...toRoleDef },
        actor: { ...actorRoleDef }
      }
    };

  } catch (error) {
    logger.error("Error in validateRoleTransition:", error);
    throw new Error("Role transition validation failed: " + (error instanceof Error ? error.message : "Unknown error"));
  }
});
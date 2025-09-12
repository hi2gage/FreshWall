/**
 * Permission system for FreshWall - Main exports and convenience functions
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import { 
  UserRole, 
  Permission, 
  ROLE_DEFINITIONS,
  getRoleDefinition,
  isHigherRole,
  roleHasPermission
} from "./types";
import {
  PermissionError,
  validateUserPermission,
  validateRoleChangePermission,
  validateTeamMembership,
  canAccessIncident,
  createAuditLog,
  getTeamUsersWithRoles,
  getUserWithRole
} from "./utils";

// Re-export types and utilities for use in other modules
export * from "./types";
export * from "./utils";

/**
 * Cloud Function: Change user role with validation and audit logging
 */
export const changeUserRole = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const { targetUserId, newRole, reason, teamId } = request.data;

    if (!targetUserId || !newRole || !teamId) {
      throw new HttpsError("invalid-argument", "Missing required parameters");
    }

    if (!Object.keys(ROLE_DEFINITIONS).includes(newRole)) {
      throw new HttpsError("invalid-argument", `Invalid role: ${newRole}`);
    }

    const actorId = request.auth.uid;

    // Validate the role change permission
    await validateRoleChangePermission(actorId, targetUserId, teamId, newRole);

    // Get current user data for audit log
    const actor = await getUserWithRole(actorId, teamId);
    const target = await getUserWithRole(targetUserId, teamId);

    if (!actor || !target) {
      throw new HttpsError("not-found", "User not found");
    }

    const oldRole = target.role;

    // Perform the role change
    await admin.firestore()
      .collection("teams")
      .doc(teamId)
      .collection("users")
      .doc(targetUserId)
      .update({
        role: newRole,
        lastModified: admin.firestore.Timestamp.now(),
        modifiedBy: actorId
      });

    // Create audit log entry
    await createAuditLog({
      action: 'role_changed',
      actorId,
      actorDisplayName: actor.displayName,
      targetUserId,
      targetDisplayName: target.displayName,
      teamId,
      details: {
        fromRole: oldRole,
        toRole: newRole,
        reason
      }
    });

    logger.info(`Role changed: ${targetUserId} from ${oldRole} to ${newRole} by ${actorId}`);

    return {
      success: true,
      oldRole,
      newRole,
      targetUserId,
      actorId
    };

  } catch (error) {
    if (error instanceof PermissionError) {
      throw new HttpsError("permission-denied", error.message);
    }
    if (error instanceof HttpsError) {
      throw error;
    }
    logger.error("Error in changeUserRole:", error);
    throw new HttpsError("internal", "Internal server error");
  }
});

/**
 * Cloud Function: Get user permissions for a team
 */
export const getUserPermissions = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const { userId, teamId } = request.data;
    const requesterId = request.auth.uid;

    if (!userId || !teamId) {
      throw new HttpsError("invalid-argument", "Missing userId or teamId");
    }

    // Validate requester is in the team
    await validateTeamMembership(requesterId, teamId);

    // Check if requester can view user permissions (self or has user management permissions)
    if (requesterId !== userId) {
      await validateUserPermission(requesterId, teamId, "users:view_all");
    }

    // Get the user's role and permissions
    const user = await getUserWithRole(userId, teamId);
    if (!user) {
      throw new HttpsError("not-found", "User not found");
    }

    const roleDef = getRoleDefinition(user.role);

    return {
      userId,
      teamId,
      role: user.role,
      permissions: roleDef.permissions,
      roleDefinition: {
        displayName: roleDef.displayName,
        description: roleDef.description,
        level: roleDef.level
      }
    };

  } catch (error) {
    if (error instanceof PermissionError) {
      throw new HttpsError("permission-denied", error.message);
    }
    if (error instanceof HttpsError) {
      throw error;
    }
    logger.error("Error in getUserPermissions:", error);
    throw new HttpsError("internal", "Internal server error");
  }
});

/**
 * Cloud Function: Get all team members with their roles and permissions
 */
export const getTeamPermissions = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const { teamId } = request.data;
    const requesterId = request.auth.uid;

    if (!teamId) {
      throw new HttpsError("invalid-argument", "Missing teamId");
    }

    // Validate requester is in the team and can view all users
    await validateUserPermission(requesterId, teamId, "users:view_all");

    // Get all team users with roles
    const users = await getTeamUsersWithRoles(teamId);

    return {
      teamId,
      users: users.map(user => ({
        userId: user.userId,
        displayName: user.displayName,
        email: user.email,
        role: user.role,
        permissions: user.permissions,
        roleDefinition: {
          displayName: getRoleDefinition(user.role).displayName,
          description: getRoleDefinition(user.role).description,
          level: getRoleDefinition(user.role).level
        },
        createdAt: user.createdAt
      }))
    };

  } catch (error) {
    if (error instanceof PermissionError) {
      throw new HttpsError("permission-denied", error.message);
    }
    if (error instanceof HttpsError) {
      throw error;
    }
    logger.error("Error in getTeamPermissions:", error);
    throw new HttpsError("internal", "Internal server error");
  }
});

/**
 * Cloud Function: Check if user has specific permission
 */
export const checkPermission = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const { permission, teamId, userId } = request.data;
    const requesterId = request.auth.uid;

    if (!permission || !teamId) {
      throw new HttpsError("invalid-argument", "Missing permission or teamId");
    }

    const checkUserId = userId || requesterId;

    // Validate requester can check permissions (self or has user management permissions)
    if (requesterId !== checkUserId) {
      await validateUserPermission(requesterId, teamId, "users:view_all");
    }

    try {
      await validateUserPermission(checkUserId, teamId, permission as Permission);
      return { hasPermission: true };
    } catch (error) {
      if (error instanceof PermissionError) {
        return { hasPermission: false, reason: error.message };
      }
      throw error;
    }

  } catch (error) {
    if (error instanceof PermissionError) {
      throw new HttpsError("permission-denied", error.message);
    }
    if (error instanceof HttpsError) {
      throw error;
    }
    logger.error("Error in checkPermission:", error);
    throw new HttpsError("internal", "Internal server error");
  }
});

/**
 * Cloud Function: Get audit logs for role changes
 */
export const getAuditLogs = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const { teamId, limit = 50, offset = 0 } = request.data;
    const requesterId = request.auth.uid;

    if (!teamId) {
      throw new HttpsError("invalid-argument", "Missing teamId");
    }

    // Validate requester has permission to view audit logs (admin permission)
    await validateUserPermission(requesterId, teamId, "users:manage_roles");

    const auditLogsSnapshot = await admin.firestore()
      .collection("teams")
      .doc(teamId)
      .collection("auditLogs")
      .orderBy("timestamp", "desc")
      .limit(limit)
      .offset(offset)
      .get();

    const auditLogs = auditLogsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    return {
      teamId,
      auditLogs,
      hasMore: auditLogsSnapshot.size === limit
    };

  } catch (error) {
    if (error instanceof PermissionError) {
      throw new HttpsError("permission-denied", error.message);
    }
    if (error instanceof HttpsError) {
      throw error;
    }
    logger.error("Error in getAuditLogs:", error);
    throw new HttpsError("internal", "Internal server error");
  }
});

/**
 * Cloud Function: Get available roles that a user can assign
 */
export const getAssignableRoles = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const { teamId } = request.data;
    const requesterId = request.auth.uid;

    if (!teamId) {
      throw new HttpsError("invalid-argument", "Missing teamId");
    }

    // Validate requester is in the team
    const requester = await validateTeamMembership(requesterId, teamId);
    
    // Get roles the requester can promote to
    const requesterRoleDef = getRoleDefinition(requester.role);
    let assignableRoles = requesterRoleDef.canPromoteTo;

    // Admins can assign any role (including admin)
    if (requester.role === "admin") {
      assignableRoles = Object.keys(ROLE_DEFINITIONS) as UserRole[];
    }

    const roles = assignableRoles.map(role => ({
      role,
      definition: getRoleDefinition(role)
    }));

    return {
      teamId,
      requesterId,
      requesterRole: requester.role,
      assignableRoles: roles
    };

  } catch (error) {
    if (error instanceof PermissionError) {
      throw new HttpsError("permission-denied", error.message);
    }
    if (error instanceof HttpsError) {
      throw error;
    }
    logger.error("Error in getAssignableRoles:", error);
    throw new HttpsError("internal", "Internal server error");
  }
});
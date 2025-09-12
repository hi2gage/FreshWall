/**
 * Permission validation utilities and helper functions
 */

import * as admin from "firebase-admin";
import { 
  UserRole, 
  Permission, 
  RoleDefinition,
  AuditLogEntry,
  ROLE_DEFINITIONS,
  getRoleDefinition,
  isHigherRole,
  roleHasPermission
} from "./types";
import * as logger from "firebase-functions/logger";

/**
 * Error class for permission-related errors
 */
export class PermissionError extends Error {
  constructor(message: string, public readonly code: string = "PERMISSION_DENIED") {
    super(message);
    this.name = "PermissionError";
  }
}

/**
 * Gets user data from Firestore with role information
 */
export async function getUserWithRole(userId: string, teamId: string): Promise<{
  displayName: string;
  email: string | null;
  role: UserRole;
  isDeleted: boolean;
  createdAt: FirebaseFirestore.Timestamp;
} | null> {
  const userDoc = await admin.firestore()
    .collection("teams")
    .doc(teamId)
    .collection("users")
    .doc(userId)
    .get();
    
  if (!userDoc.exists) {
    return null;
  }
  
  const userData = userDoc.data()!;
  return {
    displayName: userData.displayName,
    email: userData.email || null,
    role: userData.role as UserRole,
    isDeleted: userData.isDeleted || false,
    createdAt: userData.createdAt
  };
}

/**
 * Validates that a user exists and has the required permission
 */
export async function validateUserPermission(
  userId: string, 
  teamId: string, 
  requiredPermission: Permission
): Promise<void> {
  const user = await getUserWithRole(userId, teamId);
  
  if (!user) {
    throw new PermissionError(`User ${userId} not found in team ${teamId}`, "USER_NOT_FOUND");
  }
  
  if (user.isDeleted) {
    throw new PermissionError(`User ${userId} is deleted`, "USER_DELETED");
  }
  
  if (!roleHasPermission(user.role, requiredPermission)) {
    throw new PermissionError(
      `User ${userId} with role ${user.role} does not have permission ${requiredPermission}`,
      "INSUFFICIENT_PERMISSIONS"
    );
  }
}

/**
 * Validates that a user can perform a role change operation
 */
export async function validateRoleChangePermission(
  actorId: string,
  targetUserId: string, 
  teamId: string,
  newRole: UserRole
): Promise<void> {
  const actor = await getUserWithRole(actorId, teamId);
  const target = await getUserWithRole(targetUserId, teamId);
  
  if (!actor) {
    throw new PermissionError(`Actor ${actorId} not found in team ${teamId}`, "ACTOR_NOT_FOUND");
  }
  
  if (!target) {
    throw new PermissionError(`Target user ${targetUserId} not found in team ${teamId}`, "TARGET_NOT_FOUND");
  }
  
  if (actor.isDeleted) {
    throw new PermissionError(`Actor ${actorId} is deleted`, "ACTOR_DELETED");
  }
  
  if (target.isDeleted) {
    throw new PermissionError(`Target user ${targetUserId} is deleted`, "TARGET_DELETED");
  }
  
  // Check if actor has user management permissions
  if (!roleHasPermission(actor.role, "users:manage_roles")) {
    throw new PermissionError(
      `User ${actorId} does not have permission to manage user roles`,
      "INSUFFICIENT_PERMISSIONS"
    );
  }
  
  // Prevent self-role changes
  if (actorId === targetUserId) {
    throw new PermissionError(
      "Users cannot change their own role",
      "SELF_ROLE_CHANGE_DENIED"
    );
  }
  
  // Admin role can manage all roles
  if (actor.role === "admin") {
    return; // Admins can change any role to any role
  }
  
  // For non-admins, check specific role change permissions
  const actorRoleDef = getRoleDefinition(actor.role);
  
  // Check if actor can demote from current role
  if (!actorRoleDef.canDemoteFrom.includes(target.role)) {
    throw new PermissionError(
      `User ${actorId} cannot demote users from role ${target.role}`,
      "CANNOT_DEMOTE_ROLE"
    );
  }
  
  // Check if actor can promote to new role
  if (!actorRoleDef.canPromoteTo.includes(newRole)) {
    throw new PermissionError(
      `User ${actorId} cannot promote users to role ${newRole}`,
      "CANNOT_PROMOTE_ROLE"
    );
  }
  
  // Prevent promotion to equal or higher role (unless admin)
  if (isHigherRole(newRole, actor.role) || newRole === actor.role) {
    throw new PermissionError(
      `User ${actorId} cannot promote users to equal or higher role ${newRole}`,
      "CANNOT_PROMOTE_TO_HIGHER_ROLE"
    );
  }
}

/**
 * Checks if a user can access a specific incident based on role and ownership
 */
export async function canAccessIncident(
  userId: string,
  teamId: string,
  incidentId: string,
  action: 'read' | 'update' | 'delete'
): Promise<boolean> {
  try {
    const user = await getUserWithRole(userId, teamId);
    if (!user || user.isDeleted) {
      return false;
    }
    
    // Check if user has the "read/update/delete all incidents" permission
    const allPermission = `incidents:${action}_all` as Permission;
    if (roleHasPermission(user.role, allPermission)) {
      return true;
    }
    
    // Check if user has permission for their own incidents
    const ownPermission = `incidents:${action}_own` as Permission;
    if (!roleHasPermission(user.role, ownPermission)) {
      return false;
    }
    
    // Check if this is the user's own incident
    const incidentDoc = await admin.firestore()
      .collection("teams")
      .doc(teamId)
      .collection("incidents")
      .doc(incidentId)
      .get();
      
    if (!incidentDoc.exists) {
      return false;
    }
    
    const incidentData = incidentDoc.data()!;
    return incidentData.createdBy === userId || incidentData.assignedTo === userId;
    
  } catch (error) {
    logger.error("Error checking incident access:", error);
    return false;
  }
}

/**
 * Creates an audit log entry for role and permission changes
 */
export async function createAuditLog(
  entry: Omit<AuditLogEntry, 'id' | 'timestamp'>
): Promise<void> {
  try {
    const auditRef = admin.firestore()
      .collection("teams")
      .doc(entry.teamId)
      .collection("auditLogs")
      .doc();
      
    const auditEntry: AuditLogEntry = {
      ...entry,
      id: auditRef.id,
      timestamp: admin.firestore.Timestamp.now()
    };
    
    await auditRef.set(auditEntry);
    
    logger.info(`Audit log created: ${entry.action} by ${entry.actorId} on ${entry.targetUserId}`);
  } catch (error) {
    logger.error("Error creating audit log:", error);
    // Don't throw error, as audit logging should not fail the main operation
  }
}

/**
 * Batch validates multiple users have required permissions
 */
export async function batchValidatePermissions(
  userPermissionChecks: Array<{
    userId: string;
    teamId: string;
    permission: Permission;
  }>
): Promise<void> {
  const validationPromises = userPermissionChecks.map(check =>
    validateUserPermission(check.userId, check.teamId, check.permission)
  );
  
  try {
    await Promise.all(validationPromises);
  } catch (error) {
    if (error instanceof PermissionError) {
      throw error;
    }
    throw new PermissionError("Batch permission validation failed", "BATCH_VALIDATION_FAILED");
  }
}

/**
 * Gets all users in a team with their roles and permissions
 */
export async function getTeamUsersWithRoles(teamId: string): Promise<Array<{
  userId: string;
  displayName: string;
  email: string | null;
  role: UserRole;
  permissions: Permission[];
  isDeleted: boolean;
  createdAt: FirebaseFirestore.Timestamp;
}>> {
  const usersSnapshot = await admin.firestore()
    .collection("teams")
    .doc(teamId)
    .collection("users")
    .get();
    
  const users = usersSnapshot.docs.map(doc => {
    const userData = doc.data();
    const role = userData.role as UserRole;
    
    return {
      userId: doc.id,
      displayName: userData.displayName,
      email: userData.email || null,
      role,
      permissions: getRoleDefinition(role).permissions,
      isDeleted: userData.isDeleted || false,
      createdAt: userData.createdAt
    };
  });
  
  return users.filter(user => !user.isDeleted);
}

/**
 * Validates team membership and returns user data
 */
export async function validateTeamMembership(
  userId: string, 
  teamId: string
): Promise<{
  displayName: string;
  email: string | null;
  role: UserRole;
  isDeleted: boolean;
}> {
  const user = await getUserWithRole(userId, teamId);
  
  if (!user) {
    throw new PermissionError(
      `User ${userId} is not a member of team ${teamId}`,
      "NOT_TEAM_MEMBER"
    );
  }
  
  if (user.isDeleted) {
    throw new PermissionError(
      `User ${userId} is deleted`,
      "USER_DELETED"
    );
  }
  
  return user;
}
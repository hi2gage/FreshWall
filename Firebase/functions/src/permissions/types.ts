/**
 * Enhanced role-based permissions system for FreshWall
 * Provides hierarchical role management with granular permission control
 */

export type UserRole = 
  | "admin"       // Full system access, can manage all aspects of the team
  | "manager"     // Team oversight, can manage incidents and field workers
  | "field_worker"; // Basic access, can create/update own incidents only

export type Permission =
  // User Management
  | "users:create"
  | "users:read"
  | "users:update"
  | "users:delete"
  | "users:manage_roles"
  | "users:view_all"
  
  // Team Management
  | "team:update"
  | "team:delete"
  | "team:manage_settings"
  | "team:view_analytics"
  
  // Client Management
  | "clients:create"
  | "clients:read"
  | "clients:update"
  | "clients:delete"
  | "clients:view_all"
  
  // Incident Management
  | "incidents:create"
  | "incidents:read_own"
  | "incidents:read_all"
  | "incidents:update_own"
  | "incidents:update_all"
  | "incidents:delete_own"
  | "incidents:delete_all"
  | "incidents:assign"
  
  // Reporting
  | "reports:view_basic"
  | "reports:view_advanced"
  | "reports:generate"
  | "reports:export"
  
  // Invitations
  | "invitations:create"
  | "invitations:manage"
  | "invitations:view";

export interface RoleDefinition {
  name: UserRole;
  displayName: string;
  description: string;
  level: number; // Higher number = more permissions
  permissions: Permission[];
  canPromoteTo: UserRole[];
  canDemoteFrom: UserRole[];
}

export interface UserPermissions {
  userId: string;
  teamId: string;
  role: UserRole;
  permissions: Permission[];
  grantedAt: FirebaseFirestore.Timestamp;
  grantedBy: string;
  lastModified: FirebaseFirestore.Timestamp;
  modifiedBy: string;
  isActive: boolean;
}

export interface RoleChangeRequest {
  userId: string;
  fromRole: UserRole;
  toRole: UserRole;
  reason?: string;
  requestedBy: string;
  requestedAt: FirebaseFirestore.Timestamp;
}

export interface AuditLogEntry {
  id: string;
  action: 'role_granted' | 'role_revoked' | 'role_changed' | 'permission_granted' | 'permission_revoked';
  actorId: string;
  actorDisplayName: string;
  targetUserId: string;
  targetDisplayName: string;
  teamId: string;
  details: {
    fromRole?: UserRole;
    toRole?: UserRole;
    permissions?: Permission[];
    reason?: string;
    metadata?: Record<string, any>;
  };
  timestamp: FirebaseFirestore.Timestamp;
  ipAddress?: string;
  userAgent?: string;
}

/**
 * Role hierarchy and permission definitions
 */
export const ROLE_DEFINITIONS: Record<UserRole, RoleDefinition> = {
  admin: {
    name: "admin",
    displayName: "Administrator",
    description: "Full access to team management, user roles, and all features",
    level: 100,
    permissions: [
      // User Management - Full access
      "users:create", "users:read", "users:update", "users:delete", 
      "users:manage_roles", "users:view_all",
      
      // Team Management - Full access
      "team:update", "team:delete", "team:manage_settings", "team:view_analytics",
      
      // Client Management - Full access
      "clients:create", "clients:read", "clients:update", "clients:delete", "clients:view_all",
      
      // Incident Management - Full access
      "incidents:create", "incidents:read_own", "incidents:read_all",
      "incidents:update_own", "incidents:update_all", 
      "incidents:delete_own", "incidents:delete_all", "incidents:assign",
      
      // Reporting - Full access
      "reports:view_basic", "reports:view_advanced", "reports:generate", "reports:export",
      
      // Invitations - Full access
      "invitations:create", "invitations:manage", "invitations:view"
    ],
    canPromoteTo: [], // Admins can promote anyone to any role
    canDemoteFrom: [] // Admins can demote anyone from any role
  },
  
  manager: {
    name: "manager",
    displayName: "Manager", 
    description: "Team oversight, incident assignment, and reporting capabilities",
    level: 50,
    permissions: [
      // User Management - Limited
      "users:read", "users:view_all",
      
      // Team Management - Read only
      "team:view_analytics",
      
      // Client Management - Full access
      "clients:create", "clients:read", "clients:update", "clients:delete", "clients:view_all",
      
      // Incident Management - Broad access
      "incidents:create", "incidents:read_own", "incidents:read_all",
      "incidents:update_own", "incidents:update_all", 
      "incidents:delete_own", "incidents:assign",
      
      // Reporting - Advanced access
      "reports:view_basic", "reports:view_advanced", "reports:generate", "reports:export",
      
      // Invitations - Limited
      "invitations:create", "invitations:view"
    ],
    canPromoteTo: ["field_worker"],
    canDemoteFrom: ["field_worker"]
  },
  
  field_worker: {
    name: "field_worker",
    displayName: "Field Worker",
    description: "Basic access to create and manage own incidents",
    level: 10,
    permissions: [
      // User Management - Own profile only
      "users:read",
      
      // Client Management - Read only
      "clients:read",
      
      // Incident Management - Own incidents only
      "incidents:create", "incidents:read_own", "incidents:update_own", "incidents:delete_own",
      
      // Reporting - Basic access
      "reports:view_basic"
    ],
    canPromoteTo: [],
    canDemoteFrom: []
  },
  
};

/**
 * Gets the role definition for a given role
 */
export function getRoleDefinition(role: UserRole): RoleDefinition {
  return ROLE_DEFINITIONS[role];
}

/**
 * Checks if role1 has higher privileges than role2
 */
export function isHigherRole(role1: UserRole, role2: UserRole): boolean {
  return ROLE_DEFINITIONS[role1].level > ROLE_DEFINITIONS[role2].level;
}

/**
 * Gets all permissions for a given role
 */
export function getPermissionsForRole(role: UserRole): Permission[] {
  return ROLE_DEFINITIONS[role].permissions;
}

/**
 * Checks if a role has a specific permission
 */
export function roleHasPermission(role: UserRole, permission: Permission): boolean {
  return ROLE_DEFINITIONS[role].permissions.includes(permission);
}


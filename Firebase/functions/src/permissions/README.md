# Enhanced Role-Based Permissions System

This directory contains the comprehensive role-based permissions system for FreshWall, providing hierarchical role management with granular permission control.

## Overview

The system replaces the simple "lead"/"member" roles with a more sophisticated hierarchy:

- **Admin**: Full system access, can manage all aspects of the team
- **Manager**: Team oversight, can manage incidents and field workers  
- **Field Worker**: Basic access, can create/update own incidents only

Legacy "lead" and "member" roles are automatically migrated to "admin" and "field_worker" respectively.

## Architecture

### Core Components

1. **Types (`types.ts`)**: Role definitions, permissions, and type interfaces
2. **Utils (`utils.ts`)**: Permission validation and utility functions
3. **Index (`index.ts`)**: Main permission Cloud Functions
4. **Migration (`migration.ts`)**: Legacy role migration functions
5. **Role Transitions (`roleTransitions.ts`)**: Role change workflows and audit

### Permission Matrix

| Resource | Admin | Manager | Field Worker |
|----------|-------|---------|--------------|
| **Users** | Full CRUD + Role Management | Read Only | Read Only (Own Profile) |
| **Team** | Full Management | View Analytics | Basic View |
| **Clients** | Full CRUD | Full CRUD | Read Only |
| **Incidents** | Full CRUD + Assignment | Full CRUD + Assignment | Own Incidents Only |
| **Reports** | All Reports + Export | Advanced Reports | Basic Reports |
| **Invitations** | Full Management | Create + View | None |
| **Audit Logs** | Full Access | None | None |

## Cloud Functions

### Permission Management

#### `changeUserRole(targetUserId, newRole, reason, teamId)`
Changes a user's role with validation and audit logging.

```typescript
// Example usage
const result = await changeUserRole({
  targetUserId: "user123",
  newRole: "manager",
  reason: "Promoted to team lead",
  teamId: "team456"
});
```

#### `getUserPermissions(userId, teamId)`
Gets a user's current role and permissions.

#### `getTeamPermissions(teamId)`
Gets all team members with their roles and permissions.

#### `checkPermission(permission, teamId, userId?)`
Checks if a user has a specific permission.

### Migration Functions

#### `migrateTeamRoles(teamId, dryRun?)`
Migrates legacy roles to the new system for a specific team.

```typescript
// Dry run to see what would be migrated
const dryRunResult = await migrateTeamRoles({
  teamId: "team456",
  dryRun: true
});

// Actual migration
const migrationResult = await migrateTeamRoles({
  teamId: "team456",
  dryRun: false
});
```

#### `getMigrationStatus(teamId)`
Gets migration status and legacy user information for a team.

### Role Transitions

#### `requestRoleChange(targetUserId, newRole, reason, teamId)`
Requests a role change (with approval workflows for future versions).

#### `bulkChangeRoles(userIds, newRole, reason, teamId)`
Changes roles for multiple users at once.

#### `getUserRoleHistory(userId, teamId)`
Gets role change history for a user.

## Security Rules

The Firestore security rules have been updated to support the new role hierarchy:

### Key Rule Functions

```javascript
function isAdmin(teamId) {
  let role = getUserRole(teamId);
  return role == "admin" || role == "lead"; // Include legacy lead role
}

function isManager(teamId) {
  let role = getUserRole(teamId);
  return role == "manager" || isAdmin(teamId);
}

function canManageUsers(teamId) {
  return isAdmin(teamId); // Only admins can manage users
}

function canManageClients(teamId) {
  return isManager(teamId); // Managers and admins can manage clients
}
```

### Permission Inheritance

- Field Workers inherit basic permissions
- Managers inherit Field Worker permissions + management capabilities
- Admins inherit all permissions

## Migration Guide

### Automatic Migration

1. **Lead → Admin**: Former team leads become administrators
2. **Member → Field Worker**: Former members become field workers
3. **Audit Trail**: All migrations are logged for compliance

### Migration Process

```typescript
// 1. Check migration status
const status = await getMigrationStatus({ teamId: "team123" });

// 2. Run dry run to preview changes
const preview = await migrateTeamRoles({ 
  teamId: "team123", 
  dryRun: true 
});

// 3. Execute migration
const result = await migrateTeamRoles({ 
  teamId: "team123", 
  dryRun: false 
});
```

## Backward Compatibility

- Legacy roles continue to work during transition period
- New permissions automatically applied to legacy roles
- Gradual migration prevents service disruption
- Security rules handle both old and new role formats

## Audit Logging

All role changes are logged with:

- **Actor**: Who made the change
- **Target**: Who was affected
- **Details**: From/to roles, reason, metadata
- **Timestamp**: When the change occurred
- **Context**: Team, request info

### Audit Log Query

```typescript
const auditLogs = await getAuditLogs({
  teamId: "team123",
  limit: 50,
  offset: 0
});
```

## Error Handling

The system includes comprehensive error handling:

### Permission Errors

- `USER_NOT_FOUND`: User doesn't exist in team
- `INSUFFICIENT_PERMISSIONS`: User lacks required permission
- `CANNOT_PROMOTE_TO_HIGHER_ROLE`: Cannot promote to equal/higher role
- `SELF_ROLE_CHANGE_DENIED`: Users cannot change own role

### Validation Errors

- `INVALID_ROLE`: Role not recognized
- `LEGACY_ROLE_IN_NEW_INVITATION`: Cannot use legacy roles for new invites
- `USER_ALREADY_EXISTS`: User already in team

## Best Practices

### Role Assignment

1. **Principle of Least Privilege**: Start with Field Worker, promote as needed
2. **Regular Audits**: Review role assignments monthly
3. **Justification Required**: Always provide reason for role changes
4. **Bulk Operations**: Use bulk functions for multiple users

### Permission Checks

1. **Client-Side Validation**: Check permissions before UI display
2. **Server-Side Enforcement**: Always validate on backend
3. **Graceful Degradation**: Handle permission failures gracefully
4. **Cache Permissions**: Cache user permissions for better performance

### Migration Strategy

1. **Test Environment First**: Always test migration in staging
2. **Off-Peak Hours**: Migrate during low usage times
3. **Rollback Plan**: Have plan to revert if issues occur
4. **Communication**: Notify team members of role changes

## Integration Examples

### React/SwiftUI Integration

```typescript
// Check if user can manage incidents
const canManage = await checkPermission({
  permission: "incidents:update_all",
  teamId: currentTeam.id
});

// Get current user's permissions
const permissions = await getUserPermissions({
  userId: currentUser.id,
  teamId: currentTeam.id
});

// Show appropriate UI based on role
if (permissions.effectiveRole === "admin") {
  // Show admin controls
} else if (permissions.effectiveRole === "manager") {
  // Show manager controls
}
```

### Incident Management

```typescript
// Field workers can only update own incidents
// Managers can update any incident
const canUpdate = await canAccessIncident(
  userId, 
  teamId, 
  incidentId, 
  'update'
);
```

## Future Enhancements

### Planned Features

1. **Custom Roles**: Team-specific role definitions
2. **Approval Workflows**: Multi-step role change approval
3. **Time-Limited Roles**: Temporary role assignments
4. **Role Templates**: Predefined role configurations
5. **Advanced Auditing**: Detailed permission usage analytics

### API Evolution

The current API is designed to be extensible. Future versions will maintain backward compatibility while adding new capabilities.

## Support

For questions or issues with the permission system:

1. Check the audit logs for role change history
2. Use migration status endpoint to understand current state
3. Test permission changes in development environment first
4. Review Firestore security rules for client-side behavior

## Schema Changes

### User Document Structure

```typescript
{
  displayName: string;
  email: string;
  role: UserRole; // New: supports all role types
  isDeleted: boolean;
  createdAt: Timestamp;
  lastModified: Timestamp; // New: track modifications
  modifiedBy: string; // New: who made last change
  migrationDate?: Timestamp; // New: when migrated from legacy
  migratedFrom?: UserRole; // New: original legacy role
  migratedBy?: string; // New: who performed migration
}
```

### New Collections

- `teams/{teamId}/auditLogs/{logId}`: Role change audit trail
- `teams/{teamId}/roleChangeRequests/{requestId}`: Future approval workflows
- `teams/{teamId}/invitations/{invitationId}`: Enhanced invitation system
import Foundation

// MARK: - PermissionChecker

/// Utility for checking role-based permissions throughout the app.
struct PermissionChecker {
    let userRole: UserRole

    init(userRole: UserRole) {
        self.userRole = userRole
    }

    // MARK: - Team Management Permissions

    /// Can manage team members (invite, remove, change roles)
    var canManageTeamMembers: Bool {
        userRole.hasPermissionLevel(of: .manager)
    }

    /// Can view team member list
    var canViewTeamMembers: Bool {
        userRole.hasPermissionLevel(of: .fieldWorker)
    }

    /// Can change other users' roles
    var canChangeUserRoles: Bool {
        userRole.hasPermissionLevel(of: .admin)
    }

    // MARK: - Client Management Permissions

    /// Can create new clients
    var canCreateClients: Bool {
        userRole.hasPermissionLevel(of: .manager)
    }

    /// Can edit existing clients
    var canEditClients: Bool {
        userRole.hasPermissionLevel(of: .manager)
    }

    /// Can delete clients
    var canDeleteClients: Bool {
        userRole.hasPermissionLevel(of: .admin)
    }

    /// Can view client list and details
    var canViewClients: Bool {
        userRole.hasPermissionLevel(of: .fieldWorker)
    }

    // MARK: - Incident Management Permissions

    /// Can create new incidents
    var canCreateIncidents: Bool {
        userRole.hasPermissionLevel(of: .fieldWorker)
    }

    /// Can edit existing incidents
    var canEditIncidents: Bool {
        userRole.hasPermissionLevel(of: .fieldWorker)
    }

    /// Can delete incidents
    var canDeleteIncidents: Bool {
        userRole.hasPermissionLevel(of: .manager)
    }

    /// Can view incident list and details
    var canViewIncidents: Bool {
        userRole.hasPermissionLevel(of: .fieldWorker)
    }

    /// Can generate reports
    var canGenerateReports: Bool {
        userRole.hasPermissionLevel(of: .manager)
    }

    // MARK: - System Administration Permissions

    /// Can access system settings and configuration
    var canAccessSystemSettings: Bool {
        userRole.hasPermissionLevel(of: .admin)
    }

    /// Can view team statistics and analytics
    var canViewAnalytics: Bool {
        userRole.hasPermissionLevel(of: .manager)
    }

    // MARK: - Permission Checking Methods

    /// Checks if the current user can modify a specific user based on role hierarchy
    func canModifyUser(with targetRole: UserRole) -> Bool {
        // Users can only modify users with lower or equal hierarchy levels
        // Admins can modify everyone, Managers can modify Field Workers, etc.
        userRole.hierarchyLevel >= targetRole.hierarchyLevel
    }

    /// Checks if the current user can perform an action requiring a specific role level
    func hasPermissionLevel(of requiredRole: UserRole) -> Bool {
        userRole.hasPermissionLevel(of: requiredRole)
    }

    /// Returns a user-friendly description of what the role can do
    var permissionDescription: String {
        switch userRole {
        case .admin:
            "Full system access including user management, settings, and all features"
        case .manager:
            "Manage clients, generate reports, oversee team operations, and handle incidents"
        case .fieldWorker:
            "Create and manage incidents, view clients and team members"
        default:
            "Basic access to incidents and viewing capabilities"
        }
    }
}

// MARK: - UserSession Extension

extension UserSession {
    /// Returns a permission checker for this session's user role
    var permissions: PermissionChecker {
        PermissionChecker(userRole: role)
    }
}

// MARK: - AuthenticatedSessionStore Extension

extension AuthenticatedSessionStore {
    /// Returns a permission checker for the authenticated user
    var permissions: PermissionChecker {
        PermissionChecker(userRole: session.role)
    }
}

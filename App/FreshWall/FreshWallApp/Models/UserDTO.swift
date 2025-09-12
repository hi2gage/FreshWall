@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - UserRole

/// Role of a user within the team with hierarchical permissions.
enum UserRole: String, Codable, CaseIterable, Sendable {
    /// Administrator with full system permissions (highest level).
    case admin
    /// Manager with elevated permissions for team and client management.
    case manager
    /// Field worker with permissions for incident management and reporting.
    case fieldWorker = "field_worker"

    /// Returns the display name for the role.
    var displayName: String {
        switch self {
        case .admin:
            "Admin"
        case .manager:
            "Manager"
        case .fieldWorker:
            "Field Worker"
        }
    }

    /// Returns the hierarchy level for permission checking (higher = more permissions).
    var hierarchyLevel: Int {
        switch self {
        case .admin:
            3
        case .manager:
            2
        case .fieldWorker:
            1
        }
    }

    /// Returns true if this role has equal or higher permissions than the other role.
    func hasPermissionLevel(of otherRole: UserRole) -> Bool {
        hierarchyLevel >= otherRole.hierarchyLevel
    }
}

// MARK: - UserDTO

/// A user under a team, with scoped access and role-based permissions.
struct UserDTO: Codable, Identifiable, Sendable, Hashable {
    /// Firestore-generated document identifier for the user.
    @DocumentID var id: String?
    /// Display name of the user.
    var displayName: String
    /// Email address of the user (used for authentication).
    var email: String
    /// Role of the user within the team.
    var role: UserRole
    /// Flag indicating whether the user is soft-deleted.
    var isDeleted: Bool
    /// Timestamp when the user was marked deleted (if applicable).
    var deletedAt: Timestamp?
}

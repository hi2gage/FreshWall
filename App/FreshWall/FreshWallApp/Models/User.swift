@preconcurrency import FirebaseFirestore
import Foundation

/// Role of a user within the team.
enum UserRole: String, Codable, CaseIterable, Sendable {
    /// Team lead with full permissions.
    case lead
    /// Regular team member.
    case member
}

/// A user under a team, with scoped access and role-based permissions.
struct User: Codable, Identifiable, Sendable, Hashable {
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

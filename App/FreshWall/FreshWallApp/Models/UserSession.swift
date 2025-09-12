import Foundation

/// Represents an authenticated user's session, including identifiers needed for data services.
struct UserSession: Sendable, Equatable {
    /// Firebase user identifier
    let userId: String

    /// Display name of the user.
    let displayName: String

    /// Firestore team identifier
    let teamId: String

    /// User's role within the team for permission checking
    let role: UserRole

    /// Convenience initializer for backward compatibility
    init(userId: String, displayName: String, teamId: String, role: UserRole = .fieldWorker) {
        self.userId = userId
        self.displayName = displayName
        self.teamId = teamId
        self.role = role
    }
}

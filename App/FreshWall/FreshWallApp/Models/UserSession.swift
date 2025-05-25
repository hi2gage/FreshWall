import Foundation

/// Represents an authenticated user's session, including identifiers needed for data services.
struct UserSession: Sendable, Equatable {
    /// Firebase user identifier
    let userId: String

    /// Display name of the user.
    let displayName: String

    /// Firestore team identifier
    let teamId: String
}

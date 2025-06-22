import Foundation

/// Input model for creating a new member via `MemberService`.
struct AddMemberInput: Sendable {
    /// Display name of the new member.
    let displayName: String
    /// Email address of the new member.
    let email: String
    /// Role for the new member.
    let role: UserRole
}

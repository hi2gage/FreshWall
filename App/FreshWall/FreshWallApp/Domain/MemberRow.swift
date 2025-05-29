import Foundation

/// Domain model representing a team member for UI display.
struct MemberRow: Identifiable, Hashable {
    let id: String
    let displayName: String
    let email: String
    let role: String
    let isDeleted: Bool
}

extension MemberRow {
    /// Generates domain rows from Firestore users, filtering out those without IDs.
    static func makeRows(from users: [UserDTO]) -> [MemberRow] {
        users.compactMap { user in
            guard let id = user.id else { return nil }
            return MemberRow(
                id: id,
                displayName: user.displayName,
                email: user.email,
                role: user.role.rawValue.capitalized,
                isDeleted: user.isDeleted
            )
        }
    }
}

import Foundation

// MARK: - MemberRow

/// Domain model representing a team member for UI display.
struct MemberRow: Identifiable, Hashable {
    let id: String
    let displayName: String
    let email: String
    let role: String
    let isDeleted: Bool
}

extension MemberRow {
    /// Generates domain rows from members, filtering out those without IDs.
    static func makeRows(from members: [Member]) -> [MemberRow] {
        members.compactMap { member in
            guard let id = member.id else { return nil }

            return MemberRow(
                id: id,
                displayName: member.displayName,
                email: member.email,
                role: member.role.rawValue.capitalized,
                isDeleted: member.isDeleted
            )
        }
    }
}

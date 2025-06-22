import Foundation

/// Fields available for sorting members.
enum MemberSortField: SortFieldRepresentable {
    /// Sort by display name alphabetically.
    case alphabetical
    /// Sort by role type.
    case role

    var label: String {
        switch self {
        case .alphabetical: "Alphabetical"
        case .role: "Role"
        }
    }

    func icon(isSelected: Bool, isAscending: Bool) -> String? {
        guard isSelected else { return nil }
        return isAscending ? "arrow.up" : "arrow.down"
    }
}

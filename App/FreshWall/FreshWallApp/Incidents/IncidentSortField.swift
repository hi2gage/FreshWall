import Foundation

/// Fields available for sorting incidents.
enum IncidentSortField: SortFieldRepresentable {
    case alphabetical
    case date

    var label: String {
        switch self {
        case .alphabetical: "Alphabetical"
        case .date: "Date"
        }
    }

    func icon(isSelected: Bool, isAscending: Bool) -> String? {
        guard isSelected else { return nil }
        return isAscending ? "arrow.up" : "arrow.down"
    }
}

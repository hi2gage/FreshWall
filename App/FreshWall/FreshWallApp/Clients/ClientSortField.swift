import Foundation

/// Fields available for sorting clients.
enum ClientSortField: SortFieldRepresentable {
    case alphabetical
    case incidentDate

    var label: String {
        switch self {
        case .alphabetical: "Alphabetical"
        case .incidentDate: "Incident Date"
        }
    }

    func icon(isSelected: Bool, isAscending: Bool) -> String? {
        guard isSelected else { return nil }
        return isAscending ? "arrow.up" : "arrow.down"
    }
}

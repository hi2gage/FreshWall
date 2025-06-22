import Foundation
import Observation

/// ViewModel responsible for incident list presentation and data operations.
@MainActor
@Observable
final class IncidentsListViewModel {
    /// Incidents fetched from the service.
    var incidents: [Incident] = []
    /// Clients used for grouping by client name.
    var clients: [Client] = []
    /// Selected grouping option for incidents.
    var groupOption: IncidentGroupOption?
    /// Field used when sorting incidents.
    var sortField: IncidentSortField = .date
    /// Determines whether sorting is ascending or descending.
    var isAscending = false

    private let service: IncidentServiceProtocol
    private let clientService: ClientServiceProtocol

    /// Initializes the view model with a service conforming to `IncidentServiceProtocol`.
    init(incidentService: IncidentServiceProtocol, clientService: ClientServiceProtocol) {
        service = incidentService
        self.clientService = clientService
    }

    /// Loads incidents from the service.
    func loadIncidents() async {
        incidents = await (try? service.fetchIncidents()) ?? []
    }

    /// Returns incidents grouped according to the provided option and clients.
    /// - Parameters:
    ///   - option: How incidents should be grouped.
    ///   - clients: All clients used to resolve names when grouping by client.
    /// - Returns: An array of tuples where the first value is an optional group
    ///   title and the second is the incidents for that group.
    func loadClients() async {
        clients = await (try? clientService.fetchClients(sortedBy: .createdAtAscending)) ?? []
    }

    func groupedIncidents() -> [(title: String?, items: [Incident])] {
        switch groupOption {
        case .none:
            let sorted = sort(incidents)
            return [(nil, sorted)]
        case .client:
            let groups = Dictionary(grouping: incidents) { incident in
                incident.clientRef.documentID
            }
            return groups
                .map { key, value in
                    let name = clients.first { $0.id == key }?.name ?? "Unknown"
                    return (title: name, items: sort(value))
                }
                .sorted { lhs, rhs in
                    let lhsName = lhs.title ?? ""
                    let rhsName = rhs.title ?? ""
                    return isAscending ? lhsName < rhsName : lhsName > rhsName
                }
        case .date:
            let dayGroups = Dictionary(grouping: incidents) { incident in
                Calendar.current.startOfDay(for: incident.startTime.dateValue())
            }
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return dayGroups
                .map { date, value in
                    (
                        title: formatter.string(from: date),
                        items: sort(value)
                    )
                }
                .sorted { lhs, rhs in
                    guard
                        let lhsDate = formatter.date(from: lhs.title ?? ""),
                        let rhsDate = formatter.date(from: rhs.title ?? "")
                    else { return false }
                    return isAscending ? lhsDate < rhsDate : lhsDate > rhsDate
                }
        }
    }

    /// Sorts incidents using the current sort field and direction.
    private func sort(_ items: [Incident]) -> [Incident] {
        switch sortField {
        case .alphabetical:
            items.sorted { lhs, rhs in
                let lhsDesc = lhs.description
                let rhsDesc = rhs.description
                if isAscending {
                    return lhsDesc < rhsDesc
                } else {
                    return lhsDesc > rhsDesc
                }
            }
        case .date:
            items.sorted { lhs, rhs in
                let lhsDate = lhs.startTime.dateValue()
                let rhsDate = rhs.startTime.dateValue()
                if isAscending {
                    return lhsDate < rhsDate
                } else {
                    return lhsDate > rhsDate
                }
            }
        }
    }
}

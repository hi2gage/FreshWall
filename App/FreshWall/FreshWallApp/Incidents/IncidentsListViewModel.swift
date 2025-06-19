import Observation

/// ViewModel responsible for incident list presentation and data operations.
@MainActor
@Observable
final class IncidentsListViewModel {
    /// Incidents fetched from the service.
    var incidents: [IncidentDTO] = []
    /// Clients used for grouping by client name.
    var clients: [ClientDTO] = []
    /// Selected grouping option for incidents.
    var groupOption: IncidentGroupOption = .none

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

    func groupedIncidents() -> [(title: String?, items: [IncidentDTO])] {
        switch groupOption {
        case .none:
            return [(nil, incidents)]
        case .client:
            let groups = Dictionary(grouping: incidents) { incident in
                incident.clientRef.documentID
            }
            return groups.map { key, value in
                let name = clients.first { $0.id == key }?.name ?? "Unknown"
                return (title: name, items: value)
            }
            .sorted { lhs, rhs in
                (lhs.title ?? "") < (rhs.title ?? "")
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
                        items: value.sorted { lhs, rhs in
                            lhs.startTime.dateValue() < rhs.startTime.dateValue()
                        }
                    )
                }
                .sorted { lhs, rhs in
                    guard
                        let lhsDate = formatter.date(from: lhs.title ?? ""),
                        let rhsDate = formatter.date(from: rhs.title ?? "")
                    else { return false }
                    return lhsDate < rhsDate
                }
        }
    }
}

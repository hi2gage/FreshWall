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

    func groupedIncidents() -> [(title: String?, incidents: [IncidentDTO])] {
        switch groupOption {
        case .none:
            return [(nil, incidents)]
        case .client:
            let groups = Dictionary(grouping: incidents) { incident in
                incident.clientRef.documentID
            }
            return groups.map { key, value in
                let name = clients.first { $0.id == key }?.name ?? "Unknown"
                return (title: name, incidents: value)
            }
            .sorted { lhs, rhs in
                (lhs.title ?? "") < (rhs.title ?? "")
            }
        }
    }
}

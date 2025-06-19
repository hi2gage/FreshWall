import Observation

/// ViewModel responsible for incident list presentation and data operations.
@MainActor
@Observable
final class IncidentsListViewModel {
    /// Incidents fetched from the service.
    var incidents: [IncidentDTO] = []
    private let service: IncidentServiceProtocol

    /// Initializes the view model with a service conforming to `IncidentServiceProtocol`.
    init(service: IncidentServiceProtocol) {
        self.service = service
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
    func groupedIncidents(
        by option: IncidentGroupOption,
        clients: [ClientDTO]
    ) -> [(title: String?, incidents: [IncidentDTO])] {
        switch option {
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

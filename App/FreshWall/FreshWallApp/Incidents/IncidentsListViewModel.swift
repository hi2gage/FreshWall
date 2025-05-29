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
}

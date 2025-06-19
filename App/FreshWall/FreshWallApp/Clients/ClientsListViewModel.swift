import Observation

/// ViewModel responsible for client list presentation and data operations.
@MainActor
@Observable
final class ClientsListViewModel {
    /// Clients fetched from the client service.
    var clients: [ClientDTO] = []
    /// Incidents fetched from the incident service.
    var incidents: [IncidentDTO] = []

    private let clientService: ClientServiceProtocol
    private let incidentService: IncidentServiceProtocol

    /// Initializes the view model with required services.
    init(clientService: ClientServiceProtocol, incidentService: IncidentServiceProtocol) {
        self.clientService = clientService
        self.incidentService = incidentService
    }

    /// Loads clients from the service.
    func loadClients() async {
        clients = await (try? clientService.fetchClients(sortedBy: .createdAtAscending)) ?? []
    }

    /// Loads incidents from the service.
    func loadIncidents() async {
        incidents = await (try? incidentService.fetchIncidents()) ?? []
    }
}

import Observation

/// ViewModel driving the ClientsListView.
@Observable
final class ClientsListViewModel {
    /// Array of clients to display.
    var clients: [Client] = []
    private let service: ClientService

    /// Initializes with a ClientService.
    init(service: ClientService) {
        self.service = service
    }

    /// Loads clients from the service.
    func loadClients() async {
        await service.fetchClients()
        clients = service.clients
    }
}

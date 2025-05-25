import Observation

/// ViewModel responsible for client list presentation and data operations.
@Observable
final class ClientsListViewModel {
    /// Clients fetched from the service.
    var clients: [Client] = []
    private let service: ClientServiceProtocol

    /// Initializes the view model with a client service conforming to `ClientServiceProtocol`.
    init(service: ClientServiceProtocol) {
        self.service = service
    }

    /// Loads clients from the service.
    func loadClients() async {
        await service.fetchClients()
        clients = service.clients
    }
}

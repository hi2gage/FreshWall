import Observation

/// ViewModel responsible for client list presentation and data operations.
@MainActor
@Observable
final class ClientsListViewModel {
    /// Clients fetched from the service.
    var clients: [ClientDTO] = []
    private let service: ClientServiceProtocol

    /// Initializes the view model with a client service conforming to `ClientServiceProtocol`.
    init(service: ClientServiceProtocol) {
        self.service = service
    }

    /// Loads clients from the service.
    func loadClients() async {
        clients = await (try? service.fetchClients(sortedBy: .createdAtAscending)) ?? []
    }
}

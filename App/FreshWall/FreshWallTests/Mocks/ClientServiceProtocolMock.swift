@testable import FreshWall

final class ClientServiceProtocolMock: ClientServiceProtocol {
    var updateArgs: (String, UpdateClientInput)?
    var addClientResult: String = "mock-id"

    func fetchClients() async throws -> [Client] {
        []
    }

    func addClient(_: AddClientInput) async throws -> String {
        addClientResult
    }

    func updateClient(_ clientId: String, with input: UpdateClientInput) async throws {
        updateArgs = (clientId, input)
    }

    func deleteClient(_: String) async throws {
        // No-op implementation for testing
    }
}

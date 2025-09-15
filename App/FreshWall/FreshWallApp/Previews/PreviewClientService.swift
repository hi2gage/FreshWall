@preconcurrency import FirebaseFirestore
import Foundation

@MainActor
final class PreviewClientService: ClientServiceProtocol {
    func fetchClients() async throws -> [Client] {
        [Client(
            id: "client1",
            name: "Sample Client",
            notes: "Preview client",
            isDeleted: false,
            deletedAt: nil,
            createdAt: Timestamp(date: Date()),
            lastIncidentAt: Timestamp(date: Date())
        )]
    }

    func addClient(_: AddClientInput) async throws -> String {
        "preview-client-id"
    }

    func updateClient(_: String, with _: UpdateClientInput) async throws {
        // No-op implementation for previews
    }

    func deleteClient(_: String) async throws {
        // No-op implementation for previews
    }
}

import Foundation
import Observation

/// ViewModel for editing an existing client, manages form state and saving.
@MainActor
@Observable
final class EditClientViewModel {
    /// Name of the client.
    var name: String
    /// Optional notes for the client.
    var notes: String
    /// Whether to show the delete confirmation alert.
    var showingDeleteAlert = false

    private let clientId: String
    private let service: ClientServiceProtocol

    /// Validation: name must not be empty.
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(client: Client, service: ClientServiceProtocol) {
        clientId = client.id ?? ""
        self.service = service
        name = client.name
        notes = client.notes ?? ""
    }

    /// Saves the updated client via the service.
    func save() async throws {
        let input = UpdateClientInput(
            name: name.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes
        )
        try await service.updateClient(clientId, with: input)
    }

    /// Deletes the client via the service.
    func delete() async throws {
        try await service.deleteClient(clientId)
    }
}

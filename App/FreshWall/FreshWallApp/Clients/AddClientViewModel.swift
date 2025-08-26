import Foundation
import Observation

/// ViewModel for AddClientView, manages form state and saving.
@MainActor
@Observable
final class AddClientViewModel {
    /// Name of the new client.
    var name: String = ""
    /// Optional notes for the new client.
    var notes: String = ""
    private let service: ClientServiceProtocol

    /// Validation: name must not be empty.
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(service: ClientServiceProtocol) {
        self.service = service
    }

    /// Saves the new client via the service.
    /// - Returns: The ID of the newly created client.
    func save() async throws -> String {
        let input = AddClientInput(
            name: name.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes,
            lastIncidentAt: .init()
        )
        return try await service.addClient(input)
    }
}

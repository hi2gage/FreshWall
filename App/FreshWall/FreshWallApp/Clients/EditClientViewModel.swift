import Foundation
import Observation

/// ViewModel for editing an existing client, manages form state and saving.
@MainActor
@Observable
final class EditClientViewModel {
    typealias BillingMethod = ClientDTO.BillingMethod
    typealias ClientDefaults = ClientDTO.ClientDefaults
    typealias TimeRounding = ClientDTO.TimeRounding

    /// Name of the client.
    var name: String
    /// Optional notes for the client.
    var notes: String
    /// Whether to show the delete confirmation alert.
    var showingDeleteAlert = false

    // Defaults configuration
    var billingMethod: BillingMethod = .squareFootage
    var minimumBillableQuantity: String = ""
    var amountPerUnit: String = ""
    var includeDefaults: Bool = false
    var timeRounding: TimeRounding?

    private let clientId: String
    private let service: ClientServiceProtocol

    /// Validation: name must not be empty.
    var isValid: Bool {
        let nameValid = !name.trimmingCharacters(in: .whitespaces).isEmpty
        if !includeDefaults {
            return nameValid
        }

        // If including defaults, validate the billing configuration
        let quantityValid = Double(minimumBillableQuantity) != nil && Double(minimumBillableQuantity)! >= 0
        let amountValid = Double(amountPerUnit) != nil && Double(amountPerUnit)! >= 0

        return nameValid && quantityValid && amountValid
    }

    init(client: Client, service: ClientServiceProtocol) {
        clientId = client.id ?? ""
        self.service = service
        name = client.name
        notes = client.notes ?? ""

        // Load existing defaults if available
        if let defaults = client.defaults {
            billingMethod = defaults.billingMethod
            minimumBillableQuantity = String(defaults.minimumBillableQuantity)
            amountPerUnit = String(defaults.amountPerUnit)
            timeRounding = defaults.timeRounding
            includeDefaults = true
        }
    }

    /// Saves the updated client via the service.
    func save() async throws {
        let defaults: ClientDefaults? = if includeDefaults {
            ClientDefaults(
                billingMethod: billingMethod,
                minimumBillableQuantity: Double(minimumBillableQuantity) ?? 0,
                amountPerUnit: Double(amountPerUnit) ?? 0,
                timeRounding: billingMethod == .time ? timeRounding : nil
            )
        } else {
            nil
        }

        let input = UpdateClientInput(
            name: name.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes,
            defaults: defaults
        )
        try await service.updateClient(clientId, with: input)
        FWAnalytics.log(.clientEdited)
    }

    /// Deletes the client via the service.
    func delete() async throws {
        try await service.deleteClient(clientId)
        FWAnalytics.log(.clientDeleted)
    }
}

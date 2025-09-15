import Foundation
import Observation

/// ViewModel for AddClientView, manages form state and saving.
@MainActor
@Observable
final class AddClientViewModel {
    typealias BillingMethod = ClientDTO.BillingMethod
    typealias ClientDefaults = ClientDTO.ClientDefaults
    typealias TimeRounding = ClientDTO.TimeRounding

    /// Name of the new client.
    var name: String = ""
    /// Optional notes for the new client.
    var notes: String = ""

    // Defaults configuration
    var billingMethod: BillingMethod = .time
    var minimumBillableQuantity: String = ""
    var amountPerUnit: String = ""
    var includeDefaults: Bool = true
    var timeRounding: TimeRounding?

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

    init(service: ClientServiceProtocol) {
        self.service = service
    }

    /// Saves the new client via the service.
    /// - Returns: The ID of the newly created client.
    func save() async throws -> String {
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

        let input = AddClientInput(
            name: name.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes,
            defaults: defaults,
            lastIncidentAt: .init()
        )
        return try await service.addClient(input)
    }
}

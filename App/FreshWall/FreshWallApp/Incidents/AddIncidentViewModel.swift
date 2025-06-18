import Foundation
import Observation

/// ViewModel for AddIncidentView, manages form state and saving.
@MainActor
@Observable
final class AddIncidentViewModel {
    /// Client document ID or special tag for add-new.
    var clientId: String = ""
    /// Description of the incident.
    var description: String = ""
    /// Area affected (as text input).
    var areaText: String = ""
    /// Start time of incident.
    var startTime: Date = .init()
    /// End time of incident.
    var endTime: Date = .init()
    /// Whether the incident is billable.
    var billable: Bool = false
    /// Billing rate (as text input).
    var rateText: String = ""
    /// Optional project name.
    var projectName: String = ""
    /// Status of the incident.
    var status: String = "open"
    /// Materials used description.
    var materialsUsed: String = ""
    /// Available status options.
    let statusOptions = ["open", "in_progress", "completed"]
    /// Loaded clients for selection.
    var clients: [ClientDTO] = []
    private let clientService: ClientServiceProtocol
    private let service: IncidentServiceProtocol

    /// Validation: requires a clientId and description.
    var isValid: Bool {
        !clientId.trimmingCharacters(in: .whitespaces).isEmpty &&
            !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(service: IncidentServiceProtocol, clientService: ClientServiceProtocol) {
        self.service = service
        self.clientService = clientService
    }

    /// Saves the new incident via the service.
    func save() async throws {
        let areaValue = Double(areaText) ?? 0
        let rateValue = Double(rateText)
        let input = AddIncidentInput(
            clientId: clientId.trimmingCharacters(in: .whitespaces),
            description: description,
            area: areaValue,
            startTime: startTime,
            endTime: endTime,
            billable: billable,
            rate: rateValue,
            projectName: projectName.isEmpty ? nil : projectName,
            status: status,
            materialsUsed: materialsUsed.isEmpty ? nil : materialsUsed
        )
        try await service.addIncident(input)
    }

    /// Loads available clients for the picker.
    func loadClients() async {
        clients = await (try? clientService.fetchClients(sortedBy: .createdAtAscending)) ?? []
    }

    /// A list of client options with valid IDs for selection.
    var validClients: [(id: String, name: String)] {
        clients.compactMap { client in
            guard let id = client.id else { return nil }
            return (id: id, name: client.name)
        }
    }
}

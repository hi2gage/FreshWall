import Foundation
import Observation

/// ViewModel for AddIncidentView, manages form state and saving.
@MainActor
@Observable
final class AddIncidentViewModel {
    /// Container for all editable incident fields.
    struct Input {
        /// Title of the project.
        var projectTitle: String = ""
        /// Selected client document ID or tag for add-new.
        var clientId: String = ""
        /// Notes describing the incident.
        var description: String = ""
        /// Area affected as free-form text.
        var areaText: String = ""
        /// Start time of incident.
        var startTime: Date = .init()
        /// End time of incident.
        var endTime: Date = .init()
        /// Whether the incident is billable.
        var billable: Bool = false
        /// Billing rate as text.
        var rateText: String = ""
        /// Status of the incident.
        var status: String = "open"
        /// Materials used description.
        var materialsUsed: String = ""
    }

    /// Current input being edited.
    var input = Input()
    /// Available status options.
    let statusOptions = ["open", "in_progress", "completed"]
    /// Loaded clients for selection.
    var clients: [Client] = []
    private let clientService: ClientServiceProtocol
    private let service: IncidentServiceProtocol

    /// Validation: requires a clientId, description, and project title.
    var isValid: Bool {
        !input.clientId.trimmingCharacters(in: .whitespaces).isEmpty &&
            !input.description.trimmingCharacters(in: .whitespaces).isEmpty &&
            !input.projectTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(service: IncidentServiceProtocol, clientService: ClientServiceProtocol) {
        self.service = service
        self.clientService = clientService
    }

    /// Saves the new incident via the service along with photo data.
    func save(beforePhotos: [PickedPhoto], afterPhotos: [PickedPhoto]) async throws {
        let areaValue = Double(input.areaText) ?? 0
        let rateValue = Double(input.rateText)
        let input = AddIncidentInput(
            clientId: input.clientId.trimmingCharacters(in: .whitespaces),
            description: input.description,
            area: areaValue,
            startTime: input.startTime,
            endTime: input.endTime,
            billable: input.billable,
            rate: rateValue,
            projectTitle: input.projectTitle,
            status: input.status,
            materialsUsed: input.materialsUsed.isEmpty ? nil : input.materialsUsed
        )
        try await service.addIncident(
            input,
            beforePhotos: beforePhotos,
            afterPhotos: afterPhotos
        )
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

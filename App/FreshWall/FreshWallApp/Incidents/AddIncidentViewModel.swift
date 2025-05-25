import Observation
import Foundation

/// ViewModel for AddIncidentView, manages form state and saving.
@MainActor
@Observable
final class AddIncidentViewModel {
    /// Client document ID.
    var clientId: String = ""
    /// Description of the incident.
    var description: String = ""
    /// Area affected (as text input).
    var areaText: String = ""
    /// Start time of incident.
    var startTime: Date = Date()
    /// End time of incident.
    var endTime: Date = Date()
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
    private let service: IncidentServiceProtocol

    /// Validation: requires a clientId and description.
    var isValid: Bool {
        !clientId.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(service: IncidentServiceProtocol) {
        self.service = service
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
}
import _PhotosUI_SwiftUI
import FirebaseFirestore
import Foundation
import Observation

/// ViewModel for editing an existing incident.
@MainActor
@Observable
final class EditIncidentViewModel {
    /// Selected client document ID.
    var clientId: String
    /// Notes text.
    var description: String
    /// Area affected input as text.
    var areaText: String
    /// Start time for the incident.
    var startTime: Date
    /// End time for the incident.
    var endTime: Date
    /// Whether incident is billable.
    var billable: Bool
    /// Billing rate input as text.
    var rateText: String
    /// Project title.
    var projectTitle: String
    /// Incident status string.
    var status: String
    /// Materials used description.
    var materialsUsed: String
    /// Photos selected to represent the "before" state.
    var beforePhotos: [PickedPhoto] = []
    /// Photos selected to represent the "after" state.
    var afterPhotos: [PickedPhoto] = []
    /// Status options for selection.
    let statusOptions = ["open", "in_progress", "completed"]
    /// Loaded clients for selection.
    var clients: [Client] = []

    private let incidentId: String
    private let service: IncidentServiceProtocol
    private let clientService: ClientServiceProtocol

    /// Validation: requires a client, description, and project title.
    var isValid: Bool {
        !clientId.trimmingCharacters(in: .whitespaces).isEmpty &&
            !description.trimmingCharacters(in: .whitespaces).isEmpty &&
            !projectTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(incident: Incident, incidentService: IncidentServiceProtocol, clientService: ClientServiceProtocol) {
        incidentId = incident.id ?? ""
        service = incidentService
        self.clientService = clientService
        clientId = incident.clientRef?.documentID ?? ""
        description = incident.description
        areaText = String(incident.area)
        startTime = incident.startTime.dateValue()
        endTime = incident.endTime.dateValue()
        billable = incident.billable
        rateText = incident.rate.map { String($0) } ?? ""
        projectTitle = incident.projectTitle
        status = incident.status
        materialsUsed = incident.materialsUsed ?? ""
    }

    /// Saves the updated incident using the service along with new photos.
    func save(beforePhotos: [PickedPhoto], afterPhotos: [PickedPhoto]) async throws {
        let input = UpdateIncidentInput(
            clientId: clientId.trimmingCharacters(in: .whitespaces),
            description: description,
            area: Double(areaText) ?? 0,
            startTime: startTime,
            endTime: endTime,
            billable: billable,
            rate: Double(rateText),
            projectTitle: projectTitle,
            status: status,
            materialsUsed: materialsUsed.isEmpty ? nil : materialsUsed
        )
        try await service.updateIncident(
            incidentId,
            with: input,
            beforePhotos: beforePhotos,
            afterPhotos: afterPhotos
        )
    }

    /// Loads available clients for selection.
    func loadClients() async {
        clients = await (try? clientService.fetchClients()) ?? []
    }

    /// Valid client options.
    var validClients: [(id: String, name: String)] {
        clients.compactMap { client in
            guard let id = client.id else { return nil }

            return (id: id, name: client.name)
        }
    }
}

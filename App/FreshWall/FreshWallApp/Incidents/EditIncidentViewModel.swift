import FirebaseFirestore
import Foundation
import Observation
import _PhotosUI_SwiftUI

/// ViewModel for editing an existing incident.
@MainActor
@Observable
final class EditIncidentViewModel {
    /// Selected client document ID.
    var clientId: String
    /// Description text.
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
    /// Optional project name.
    var projectName: String
    /// Incident status string.
    var status: String
    /// Materials used description.
    var materialsUsed: String
    /// Picker selections for before photos.
    var beforePickerItems: [PhotosPickerItem] = []
    /// Picker selections for after photos.
    var afterPickerItems: [PhotosPickerItem] = []
    /// Images chosen for before state.
    var beforeImages: [UIImage] = []
    /// Images chosen for after state.
    var afterImages: [UIImage] = []
    /// Status options for selection.
    let statusOptions = ["open", "in_progress", "completed"]
    /// Loaded clients for selection.
    var clients: [ClientDTO] = []

    private let incidentId: String
    private let service: IncidentServiceProtocol
    private let clientService: ClientServiceProtocol

    /// Validation: requires a client and description.
    var isValid: Bool {
        !clientId.trimmingCharacters(in: .whitespaces).isEmpty &&
            !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(incident: IncidentDTO, incidentService: IncidentServiceProtocol, clientService: ClientServiceProtocol) {
        incidentId = incident.id ?? ""
        service = incidentService
        self.clientService = clientService
        clientId = incident.clientRef.documentID
        description = incident.description
        areaText = String(incident.area)
        startTime = incident.startTime.dateValue()
        endTime = incident.endTime.dateValue()
        billable = incident.billable
        rateText = incident.rate.map { String($0) } ?? ""
        projectName = incident.projectName ?? ""
        status = incident.status
        materialsUsed = incident.materialsUsed ?? ""
    }

    /// Saves the updated incident using the service along with new photos.
    func save(beforeImages: [Data], afterImages: [Data]) async throws {
        let input = UpdateIncidentInput(
            clientId: clientId.trimmingCharacters(in: .whitespaces),
            description: description,
            area: Double(areaText) ?? 0,
            startTime: startTime,
            endTime: endTime,
            billable: billable,
            rate: Double(rateText),
            projectName: projectName.isEmpty ? nil : projectName,
            status: status,
            materialsUsed: materialsUsed.isEmpty ? nil : materialsUsed
        )
        try await service.updateIncident(
            incidentId,
            with: input,
            beforeImages: beforeImages,
            afterImages: afterImages
        )
    }

    /// Loads available clients for selection.
    func loadClients() async {
        clients = await (try? clientService.fetchClients(sortedBy: .createdAtAscending)) ?? []
    }

    /// Valid client options.
    var validClients: [(id: String, name: String)] {
        clients.compactMap { client in
            guard let id = client.id else { return nil }
            return (id: id, name: client.name)
        }
    }
}

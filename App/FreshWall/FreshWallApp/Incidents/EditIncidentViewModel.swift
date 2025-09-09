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
    /// Billing rate input as text.
    var rateText: String
    /// Materials used description.
    var materialsUsed: String
    /// Geographic location where incident occurred.
    var location: GeoPoint?
    /// Photos selected to represent the "before" state.
    var beforePhotos: [PickedPhoto] = []
    /// Photos selected to represent the "after" state.
    var afterPhotos: [PickedPhoto] = []
    /// Loaded clients for selection.
    var clients: [Client] = []
    /// Whether to show the delete confirmation alert.
    var showingDeleteAlert = false
    /// Whether to show the location map.
    var showingLocationMap = false

    private let incidentId: String
    private let service: IncidentServiceProtocol
    private let clientService: ClientServiceProtocol

    /// Validation: requires a client and description.
    var isValid: Bool {
        !clientId.trimmingCharacters(in: .whitespaces).isEmpty &&
            !description.trimmingCharacters(in: .whitespaces).isEmpty
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
        rateText = incident.rate.map { String($0) } ?? ""
        materialsUsed = incident.materialsUsed ?? ""
        location = incident.location
    }

    /// Saves the updated incident using the service along with new photos.
    func save(beforePhotos: [PickedPhoto], afterPhotos: [PickedPhoto]) async throws {
        // Try to extract location from new photos if not manually set
        let finalLocation = location ?? LocationService.extractLocation(from: beforePhotos + afterPhotos)

        let input = UpdateIncidentInput(
            clientId: clientId.trimmingCharacters(in: .whitespaces),
            description: description,
            area: Double(areaText) ?? 0,
            location: finalLocation,
            startTime: startTime,
            endTime: endTime,
            rate: Double(rateText),
            materialsUsed: materialsUsed.isEmpty ? nil : materialsUsed
        )
        try await service.updateIncident(
            incidentId,
            with: input,
            beforePhotos: beforePhotos,
            afterPhotos: afterPhotos
        )
    }

    /// Deletes the incident via the service.
    func delete() async throws {
        try await service.deleteIncident(incidentId)
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

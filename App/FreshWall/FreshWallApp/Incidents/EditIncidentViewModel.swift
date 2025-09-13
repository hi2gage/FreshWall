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
    /// Photos selected to represent the "before" state.
    var beforePhotos: [PickedPhoto] = []
    /// Photos selected to represent the "after" state.
    var afterPhotos: [PickedPhoto] = []
    /// Loaded clients for selection.
    var clients: [Client] = []
    /// Whether to show the delete confirmation alert.
    var showingDeleteAlert = false
    /// Whether to show the enhanced location capture view.
    var showingEnhancedLocationCapture = false
    /// Whether to show surface type selection.
    var showingSurfaceTypeSelection = false
    /// Whether to show enhanced notes editing.
    var showingEnhancedNotes = false

    // MARK: - Enhanced Metadata

    /// Enhanced location data with address and capture method
    var enhancedLocation: IncidentLocation?
    /// Type of surface being worked on
    var surfaceType: SurfaceType?
    /// Structured notes system for different work stages
    var enhancedNotes: IncidentNotes?
    /// Custom surface description when surfaceType is .other
    var customSurfaceDescription: String?

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

        // Initialize enhanced metadata
        enhancedLocation = incident.enhancedLocation
        surfaceType = incident.surfaceType
        enhancedNotes = incident.enhancedNotes
        customSurfaceDescription = incident.customSurfaceDescription
    }

    /// Saves the updated incident using the service along with new photos.
    func save(beforePhotos: [PickedPhoto], afterPhotos: [PickedPhoto]) async throws {
        // Use enhanced location if available, otherwise extract from photos
        let finalEnhancedLocation = enhancedLocation ?? {
            if let photoLocation = LocationService.extractLocation(from: beforePhotos + afterPhotos) {
                return IncidentLocation(photoMetadataCoordinates: photoLocation)
            }
            return nil
        }()

        let input = UpdateIncidentInput(
            clientId: clientId.trimmingCharacters(in: .whitespaces),
            description: description,
            area: Double(areaText) ?? 0,
            startTime: startTime,
            endTime: endTime,
            rate: Double(rateText),
            materialsUsed: materialsUsed.isEmpty ? nil : materialsUsed,
            enhancedLocation: finalEnhancedLocation,
            surfaceType: surfaceType,
            enhancedNotes: enhancedNotes,
            customSurfaceDescription: customSurfaceDescription
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

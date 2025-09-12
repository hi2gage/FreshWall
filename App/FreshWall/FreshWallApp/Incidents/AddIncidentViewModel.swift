@preconcurrency import FirebaseFirestore
import Foundation
import Observation

/// ViewModel for AddIncidentView, manages form state and saving.
@MainActor
@Observable
final class AddIncidentViewModel {
    /// Container for all editable incident fields.
    struct Input {
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
        /// Billing rate as text.
        var rateText: String = ""
        /// Materials used description.
        var materialsUsed: String = ""
        /// Geographic location where incident occurred.
        var location: GeoPoint?

        // MARK: - Enhanced Metadata

        /// Enhanced location data with address and capture method
        var enhancedLocation: IncidentLocation?
        /// Type of surface being worked on
        var surfaceType: SurfaceType?
        /// Structured notes system for different work stages
        var enhancedNotes: IncidentNotes?
        /// Custom surface description when surfaceType is .other
        var customSurfaceDescription: String?
    }

    /// Current input being edited.
    var input = Input()
    /// Loaded clients for selection.
    var clients: [Client] = []
    /// Whether to show the location map.
    var showingLocationMap = false
    /// Whether to show the enhanced location capture view.
    var showingEnhancedLocationCapture = false
    /// Whether to show surface type selection.
    var showingSurfaceTypeSelection = false
    /// Whether to show enhanced notes editing.
    var showingEnhancedNotes = false
    private let clientService: ClientServiceProtocol
    private let service: IncidentServiceProtocol

    /// Validation: requires either legacy description or enhanced notes with content.
    var isValid: Bool {
        let hasLegacyDescription = !input.description.trimmingCharacters(in: .whitespaces).isEmpty
        let hasEnhancedNotes = input.enhancedNotes?.hasAnyNotes == true
        return hasLegacyDescription || hasEnhancedNotes
    }

    init(service: IncidentServiceProtocol, clientService: ClientServiceProtocol) {
        self.service = service
        self.clientService = clientService
    }

    /// Saves the new incident via the service along with photo data.
    func save(beforePhotos: [PickedPhoto], afterPhotos: [PickedPhoto]) async throws {
        let areaValue = Double(input.areaText) ?? 0
        let rateValue = Double(input.rateText)
        let trimmedId = input.clientId.trimmingCharacters(in: .whitespaces)

        // Try to extract location from photos if not manually set
        let finalLocation = input.location ?? LocationService.extractLocation(from: beforePhotos + afterPhotos)

        // Use enhanced location if available, otherwise create from legacy location
        let finalEnhancedLocation = input.enhancedLocation ?? finalLocation.map { IncidentLocation(photoMetadataCoordinates: $0) }

        let input = AddIncidentInput(
            clientId: trimmedId.isEmpty ? nil : trimmedId,
            description: input.description,
            area: areaValue,
            location: finalLocation,
            startTime: input.startTime,
            endTime: input.endTime,
            rate: rateValue,
            materialsUsed: input.materialsUsed.isEmpty ? nil : input.materialsUsed,
            enhancedLocation: finalEnhancedLocation,
            surfaceType: input.surfaceType,
            enhancedNotes: input.enhancedNotes,
            customSurfaceDescription: input.customSurfaceDescription
        )
        try await service.addIncident(
            input,
            beforePhotos: beforePhotos,
            afterPhotos: afterPhotos
        )
    }

    /// Loads available clients for the picker.
    func loadClients() async {
        clients = await (try? clientService.fetchClients()) ?? []
    }

    /// A list of client options with valid IDs for selection.
    var validClients: [(id: String, name: String)] {
        clients.compactMap { client in
            guard let id = client.id else { return nil }

            return (id: id, name: client.name)
        }
    }
}

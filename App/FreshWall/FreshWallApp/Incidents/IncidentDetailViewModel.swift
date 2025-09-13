import _PhotosUI_SwiftUI
import Foundation
import Observation

/// ViewModel for displaying and managing incident details.
@MainActor
@Observable
final class IncidentDetailViewModel {
    /// The current incident being displayed.
    var incident: Incident
    /// The client associated with this incident.
    var client: Client?
    /// All available clients for selection.
    var clients: [Client] = []
    /// Currently selected client ID for editing.
    var selectedClientId: String?
    /// Photos selected for before state.
    var pickedBeforePhotos: [PickedPhoto] = []
    /// Photos selected for after state.
    var pickedAfterPhotos: [PickedPhoto] = []

    private let incidentService: IncidentServiceProtocol
    private let clientService: ClientServiceProtocol

    /// Initializes the view model with an incident and required services.
    init(incident: Incident, incidentService: IncidentServiceProtocol, clientService: ClientServiceProtocol) {
        self.incident = incident
        self.incidentService = incidentService
        self.clientService = clientService
    }

    /// Reloads the incident after editing.
    func reloadIncident() async {
        guard let id = incident.id else { return }

        let updated = await (try? incidentService.fetchIncidents()) ?? []
        if let match = updated.first(where: { $0.id == id }) {
            incident = match
        }
        await loadClient()
    }

    /// Loads the client associated with this incident and all available clients.
    func loadClient() async {
        clients = await (try? clientService.fetchClients()) ?? []
        client = clients.first { $0.id == incident.clientRef?.documentID }
        selectedClientId = incident.clientRef?.documentID
    }

    /// Updates the incident with new photos.
    func updateIncidentWithPhotos(beforePhotos: [PickedPhoto], afterPhotos: [PickedPhoto]) async {
        guard let id = incident.id else { return }

        let input = UpdateIncidentInput(
            clientId: selectedClientId ?? incident.clientRef?.documentID,
            description: incident.description,
            area: incident.area,
            startTime: incident.startTime.dateValue(),
            endTime: incident.endTime.dateValue(),
            rate: incident.rate,
            materialsUsed: incident.materialsUsed,
            enhancedLocation: incident.enhancedLocation,
            surfaceType: incident.surfaceType,
            enhancedNotes: incident.enhancedNotes,
            customSurfaceDescription: incident.customSurfaceDescription
        )

        do {
            try await incidentService.updateIncident(
                id,
                with: input,
                beforePhotos: beforePhotos,
                afterPhotos: afterPhotos
            )
            await reloadIncident()
        } catch {
            print("Failed to update incident with photos: \(error)")
        }
    }

    /// Updates the incident with current values.
    func updateIncident() async {
        guard let id = incident.id else { return }

        let input = UpdateIncidentInput(
            clientId: selectedClientId ?? incident.clientRef?.documentID,
            description: incident.description,
            area: incident.area,
            startTime: incident.startTime.dateValue(),
            endTime: incident.endTime.dateValue(),
            rate: incident.rate,
            materialsUsed: incident.materialsUsed,
            enhancedLocation: incident.enhancedLocation,
            surfaceType: incident.surfaceType,
            enhancedNotes: incident.enhancedNotes,
            customSurfaceDescription: incident.customSurfaceDescription
        )

        do {
            try await incidentService.updateIncident(
                id,
                with: input,
                beforePhotos: [],
                afterPhotos: []
            )
            await reloadIncident()
        } catch {
            print("Failed to update incident: \(error)")
        }
    }

    /// Clears picked photos after processing.
    func clearPickedPhotos() {
        pickedBeforePhotos.removeAll()
        pickedAfterPhotos.removeAll()
    }

    /// Handles when a new client is created
    func handleNewClientCreated(_ clientId: String) async {
        // Load the updated client list
        clients = await (try? clientService.fetchClients()) ?? []

        // Set the selected client to the new one
        selectedClientId = clientId

        // Update the incident with the new client selection
        guard let id = incident.id else { return }

        let input = UpdateIncidentInput(
            clientId: selectedClientId ?? incident.clientRef?.documentID,
            description: incident.description,
            area: incident.area,
            startTime: incident.startTime.dateValue(),
            endTime: incident.endTime.dateValue(),
            rate: incident.rate,
            materialsUsed: incident.materialsUsed,
            enhancedLocation: incident.enhancedLocation,
            surfaceType: incident.surfaceType,
            enhancedNotes: incident.enhancedNotes,
            customSurfaceDescription: incident.customSurfaceDescription
        )

        do {
            try await incidentService.updateIncident(id, with: input, beforePhotos: [], afterPhotos: [])

            // Reload the incident data but preserve our client selection
            let updated = await (try? incidentService.fetchIncidents()) ?? []
            if let match = updated.first(where: { $0.id == id }) {
                incident = match
            }
            // Update the client object to match our selection
            client = clients.first { $0.id == selectedClientId }
        } catch {
            print("Failed to update incident: \(error)")
        }
    }
}

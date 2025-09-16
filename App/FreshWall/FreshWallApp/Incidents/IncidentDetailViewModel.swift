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
    var selectedClientId: String? {
        didSet {
            print("changed to: \(selectedClientId ?? "nil")")
        }
    }

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

        if let freshIncident = try? await incidentService.fetchIncident(id: id) {
            incident = freshIncident
        }
        await loadClient()
    }

    /// Loads the client associated with this incident and all available clients.
    func loadClient() async {
        print("🔄 Loading client data...")

        // Set the selected client ID from the incident first
        selectedClientId = incident.clientRef?.documentID

        // Use the new service method that handles all the caching logic
        let result = await clientService.fetchAllClientsWithPriority(priorityClientId: selectedClientId)

        client = result.priorityClient
        clients = result.allClients

        print("✅ Client loading complete - loaded \(clients.count) clients")
        if let client {
            print("✅ Priority client: \(client.name)")
        } else {
            print("✅ No client associated with incident")
        }
    }

    /// Updates the incident with optional modifications.
    func updateIncident(
        newLocation: IncidentLocation? = nil,
        beforePhotos: [PickedPhoto] = [],
        afterPhotos: [PickedPhoto] = [],
        newClientId: String? = nil
    ) async {
        guard let id = incident.id else { return }

        // Apply any location changes to the incident model
        if let newLocation {
            incident.enhancedLocation = newLocation
        }

        // Determine the client ID to use
        let clientId = newClientId ?? selectedClientId ?? incident.clientRef?.documentID

        let input = UpdateIncidentInput(
            clientId: clientId,
            description: incident.description,
            area: incident.area,
            startTime: incident.startTime.dateValue(),
            endTime: incident.endTime.dateValue(),
            rate: incident.rate,
            materialsUsed: incident.materialsUsed,
            enhancedLocation: incident.enhancedLocation,
            surfaceType: incident.surfaceType,
            enhancedNotes: incident.enhancedNotes,
            customSurfaceDescription: incident.customSurfaceDescription,
            billing: incident.billing
        )

        do {
            try await incidentService.updateIncident(
                id,
                with: input,
                beforePhotos: beforePhotos,
                afterPhotos: afterPhotos
            )

            // Only reload if we updated photos or location
            // For simple client changes, avoid the full reload cycle
            let hasPhotos = !beforePhotos.isEmpty || !afterPhotos.isEmpty
            let hasLocationChange = newLocation != nil

            if hasPhotos || hasLocationChange {
                await reloadIncident()
            }
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
        // Invalidate cache since we have new client data
        await ClientCache.shared.invalidate()

        // Load the updated client list
        clients = await (try? clientService.fetchClients()) ?? []

        // Set the selected client to the new one
        selectedClientId = clientId

        // Update the incident with the new client selection
        await updateIncident(newClientId: clientId)

        // Update the client object to match our selection
        client = clients.first { $0.id == selectedClientId }
    }

    /// Deletes the incident.
    func deleteIncident() async throws {
        guard let id = incident.id else {
            throw NSError(domain: "IncidentDetailViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Incident ID not found"])
        }

        try await incidentService.deleteIncident(id)
    }
}

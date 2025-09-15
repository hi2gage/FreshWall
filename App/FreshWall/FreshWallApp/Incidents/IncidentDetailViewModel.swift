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
        print("🔄 Loading client data...")

        // Set the selected client ID from the incident first
        selectedClientId = incident.clientRef?.documentID

        // Try cache first
        let cache = ClientCache.shared
        let cachedClients = cache.getAllClients()
        let cachedClient = selectedClientId.flatMap { cache.getClient(id: $0) }

        if let cachedClients, let selectedClientId, let cachedClient {
            // Cache hit - use cached data instantly
            client = cachedClient
            clients = [cachedClient] + cachedClients.filter { $0.id != selectedClientId }
            print("⚡ Used cached client data: \(cachedClient.name)")
            return
        }

        print("💾 Cache miss - fetching from Firestore...")

        // Cache miss - fetch from Firestore
        async let allClientsTask = clientService.fetchClients()
        async let specificClientTask = loadSpecificClient()

        // Await both results
        let allClientsResult = await (try? allClientsTask) ?? []
        let specificClient = await specificClientTask

        // Update cache with fresh data
        cache.updateCache(clients: allClientsResult)
        if let specificClient {
            cache.updateClient(specificClient)
        }

        // Set the specific client first (priority)
        client = specificClient
        print("✅ Specific client loaded: \(client?.name ?? "No client")")

        // Then set all clients, but ensure the selected client appears first in the list
        if let selectedClient = client {
            // Put the selected client first, then all others
            clients = [selectedClient] + allClientsResult.filter { $0.id != selectedClient.id }
            print("✅ Loaded \(allClientsResult.count) clients with selected client first")
        } else {
            clients = allClientsResult
            print("✅ Loaded \(allClientsResult.count) clients")
        }

        print("✅ Client loading complete")
    }

    /// Helper method to load the specific client using DocumentReference
    private func loadSpecificClient() async -> Client? {
        guard let clientRef = incident.clientRef else {
            print("ℹ️ No client reference found")
            return nil
        }

        print("📖 Fetching specific client directly from reference...")
        do {
            let clientDoc = try await clientRef.getDocument()
            if clientDoc.exists {
                let clientDTO = try clientDoc.data(as: ClientDTO.self)
                let client = Client(dto: clientDTO)
                print("✅ Fetched client directly: \(client.name)")
                return client
            } else {
                print("⚠️ Client document doesn't exist")
                return nil
            }
        } catch {
            print("⚠️ Direct fetch failed: \(error)")
            return nil
        }
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
            await reloadIncident()
        } catch {
            print("Failed to update incident with photos: \(error)")
        }
    }

    /// Updates the incident with a new location.
    func updateIncidentLocation(_ newLocation: IncidentLocation) async {
        guard let id = incident.id else { return }

        // Update the incident's location
        incident.enhancedLocation = newLocation

        let input = UpdateIncidentInput(
            clientId: selectedClientId ?? incident.clientRef?.documentID,
            description: incident.description,
            area: incident.area,
            startTime: incident.startTime.dateValue(),
            endTime: incident.endTime.dateValue(),
            rate: incident.rate,
            materialsUsed: incident.materialsUsed,
            enhancedLocation: newLocation,
            surfaceType: incident.surfaceType,
            enhancedNotes: incident.enhancedNotes,
            customSurfaceDescription: incident.customSurfaceDescription,
            billing: incident.billing
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
            print("Failed to update incident location: \(error)")
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
            customSurfaceDescription: incident.customSurfaceDescription,
            billing: incident.billing
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
        // Invalidate cache since we have new client data
        ClientCache.shared.invalidate()

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
            customSurfaceDescription: incident.customSurfaceDescription,
            billing: incident.billing
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

    /// Deletes the incident.
    func deleteIncident() async throws {
        guard let id = incident.id else {
            throw NSError(domain: "IncidentDetailViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Incident ID not found"])
        }

        try await incidentService.deleteIncident(id)
    }
}

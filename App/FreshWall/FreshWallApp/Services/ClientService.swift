@preconcurrency import FirebaseFirestore
import Foundation
import os

// MARK: - ClientServiceProtocol

/// Protocol defining operations for fetching and managing Client entities.
protocol ClientServiceProtocol: Sendable {
    /// Fetches active clients for the current team.
    func fetchClients() async throws -> [Client]
    /// Fetches a specific client by ID with caching support.
    func fetchClientWithCache(id: String) async -> Client?
    /// Fetches all clients with optional priority client first, using cache when available.
    func fetchAllClientsWithPriority(priorityClientId: String?) async -> (priorityClient: Client?, allClients: [Client])
    /// Adds a new client using an input value object.
    /// - Returns: The ID of the newly created client.
    func addClient(_ input: AddClientInput) async throws -> String
    /// Updates an existing client using an input value object.
    func updateClient(_ clientId: String, with input: UpdateClientInput) async throws
    /// Deletes an existing client.
    func deleteClient(_ clientId: String) async throws
}

// MARK: - ClientService

/// Service to fetch and manage ``Client`` entities for the current team.
///
/// All direct Firestore interaction is delegated to a ``ClientModelServiceProtocol``
/// instance to keep this type focused on higher level business logic.
struct ClientService: ClientServiceProtocol {
    private let modelService: ClientModelServiceProtocol
    private let session: UserSession
    private let logger = Logger.freshWall(category: "ClientService")

    /// Initializes the service.
    /// - Parameters:
    ///   - firestore: Firestore instance used by the default ``ClientModelService``.
    ///   - modelService: Optional custom model service for testing.
    ///   - session: The current user session providing team context.
    init(
        modelService: ClientModelServiceProtocol,
        session: UserSession
    ) {
        self.modelService = modelService
        self.session = session
    }

    /// Fetches active clients for the current team from Firestore.
    func fetchClients() async throws -> [Client] {
        let teamId = session.teamId
        let dtos = try await modelService.fetchClients(teamId: teamId)
        return dtos.map { Client(dto: $0) }
    }

    /// Fetches a specific client by ID with caching support.
    func fetchClientWithCache(id: String) async -> Client? {
        let cache = ClientCache.shared

        // Try cache first
        if let cachedClient = await cache.getClient(id: id) {
            logger.info("⚡ Found client in cache: \(cachedClient.name)")
            return cachedClient
        }

        logger.info("💾 Cache miss for client \(id), fetching from Firestore...")

        // Cache miss - fetch from Firestore using document reference
        let teamId = session.teamId
        do {
            let clientRef = Firestore.firestore()
                .collection("teams").document(teamId)
                .collection("clients").document(id)

            let document = try await clientRef.getDocument()
            if document.exists {
                let dto = try document.data(as: ClientDTO.self)
                let client = Client(dto: dto)
                await cache.updateClient(client)
                logger.info("✅ Fetched client from Firestore: \(client.name)")
                return client
            } else {
                logger.error("⚠️ Client document doesn't exist: \(id)")
                return nil
            }
        } catch {
            logger.error("⚠️ Failed to fetch client \(id): \(error.localizedDescription)")
            return nil
        }
    }

    /// Fetches all clients with optional priority client first, using cache when available.
    func fetchAllClientsWithPriority(
        priorityClientId: String?
    ) async -> (priorityClient: Client?, allClients: [Client]) {
        let cache = ClientCache.shared
        let cachedClients = await cache.getAllClients()
        let cachedPriorityClient = await priorityClientId.asyncFlatMap {
            await cache.getClient(id: $0)
        }

        // If we have both cached clients and priority client, use cache
        if let cachedClients, let priorityClientId, let cachedPriorityClient {
            logger.info("⚡ Using cached client data for priority client: \(cachedPriorityClient.name)")
            let orderedClients = [cachedPriorityClient] + cachedClients.filter { $0.id != priorityClientId }
            return (cachedPriorityClient, orderedClients)
        }

        logger.info("💾 Cache miss - fetching clients from Firestore...")

        // Cache miss - fetch from Firestore
        async let allClientsTask = try? fetchClients()
        async let priorityClientTask = priorityClientId != nil ? fetchClientWithCache(id: priorityClientId!) : nil

        // Await both results
        let allClientsResult = await allClientsTask ?? []
        let priorityClient = await priorityClientTask

        // Update cache with fresh data
        await cache.updateCache(clients: allClientsResult)
        if let priorityClient {
            await cache.updateClient(priorityClient)
        }

        logger.info("✅ Fetched \(allClientsResult.count) clients from service")
        if let priorityClient {
            logger.info("✅ Priority client: \(priorityClient.name)")
            // Put priority client first, then all others
            let orderedClients = [priorityClient] + allClientsResult.filter { $0.id != priorityClient.id }
            return (priorityClient, orderedClients)
        } else {
            logger.info("✅ No priority client specified")
            return (nil, allClientsResult)
        }
    }

    /// Adds a new client using an input value object.
    /// - Returns: The ID of the newly created client.
    func addClient(_ input: AddClientInput) async throws -> String {
        let teamId = session.teamId

        let newDoc = modelService.newClientDocument(teamId: teamId)
        let newClient = ClientDTO(
            id: nil,
            name: input.name,
            notes: input.notes,
            defaults: input.defaults,
            isDeleted: false,
            deletedAt: nil,
            createdAt: Timestamp(date: Date()),
            lastIncidentAt: input.lastIncidentAt
        )
        try await modelService.setClient(newClient, at: newDoc)
        return newDoc.documentID
    }

    /// Updates an existing client document in Firestore.
    func updateClient(_ clientId: String, with input: UpdateClientInput) async throws {
        let teamId = session.teamId

        var data: [String: Any] = ["name": input.name]
        if let notes = input.notes {
            data["notes"] = notes
        } else {
            data["notes"] = FieldValue.delete()
        }

        if let defaults = input.defaults {
            data["defaults"] = try Firestore.Encoder().encode(defaults)
        } else {
            data["defaults"] = FieldValue.delete()
        }

        try await modelService.updateClient(id: clientId, teamId: teamId, data: data)
    }

    /// Deletes an existing client document from Firestore.
    func deleteClient(_ clientId: String) async throws {
        let teamId = session.teamId
        try await modelService.deleteClient(id: clientId, teamId: teamId)
    }
}

// MARK: ClientService.Errors

extension ClientService {
    enum Errors: Error {
        case missingTeamId
    }
}

extension Optional {
    func asyncFlatMap<T>(
        _ transform: (Wrapped) async throws -> T?
    ) async rethrows -> T? {
        switch self {
        case let .some(value):
            try await transform(value)
        case .none:
            nil
        }
    }
}

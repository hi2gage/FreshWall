import Foundation

/// Simple in-memory cache for frequently accessed clients
actor ClientCache {
    static let shared = ClientCache()

    private var clientsById: [String: Client] = [:]
    private var allClients: [Client] = []
    private var lastFetchTime: Date?
    private let cacheExpiryDuration: TimeInterval = 300 // 5 minutes

    private init() {}

    /// Check if cache is still valid
    private var isCacheValid: Bool {
        guard let lastFetchTime else { return false }

        return Date().timeIntervalSince(lastFetchTime) < cacheExpiryDuration
    }

    /// Get client by ID from cache
    func getClient(id: String) -> Client? {
        guard isCacheValid else { return nil }

        return clientsById[id]
    }

    /// Get all clients from cache
    func getAllClients() -> [Client]? {
        guard isCacheValid else { return nil }

        return allClients
    }

    /// Update cache with new client data
    func updateCache(clients: [Client]) {
        allClients = clients
        clientsById = Dictionary(uniqueKeysWithValues: clients.compactMap { client in
            guard let id = client.id else { return nil }

            return (id, client)
        })
        lastFetchTime = Date()
    }

    /// Add or update a single client in cache
    func updateClient(_ client: Client) {
        guard let id = client.id else { return }

        clientsById[id] = client

        // Update in allClients array
        if let index = allClients.firstIndex(where: { $0.id == id }) {
            allClients[index] = client
        } else {
            allClients.append(client)
        }

        // Don't update lastFetchTime for single updates
    }

    /// Invalidate cache (force refresh on next request)
    func invalidate() {
        clientsById.removeAll()
        allClients.removeAll()
        lastFetchTime = nil
    }
}

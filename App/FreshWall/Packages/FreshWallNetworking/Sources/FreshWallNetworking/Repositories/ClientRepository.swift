import Foundation

public protocol ClientRepository {
    func createClient(teamId: String, client: ClientCreate) async throws -> Client
    func getClient(clientId: String, teamId: String) async throws -> Client
    func getClientsForTeam(teamId: String) async throws -> [Client]
    func updateClient(clientId: String, teamId: String, updates: ClientUpdate) async throws
    func deleteClient(clientId: String, teamId: String) async throws
}

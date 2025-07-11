import Foundation

public protocol TeamRepository {
    func createTeam(name: String, userId: String, userName: String) async throws -> Team
    func getTeam(teamId: String) async throws -> Team
    func getTeamsForUser(userId: String) async throws -> [Team]
}

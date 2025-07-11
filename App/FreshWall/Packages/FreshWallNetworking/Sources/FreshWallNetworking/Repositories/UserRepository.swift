import Foundation

public protocol UserRepository {
    func createUser(userId: String, email: String, name: String, teamId: String, role: UserRole) async throws -> User
    func getUser(userId: String, teamId: String) async throws -> User
    func getUsersForTeam(teamId: String) async throws -> [User]
    func updateUser(userId: String, teamId: String, updates: UserUpdate) async throws
    func deleteUser(userId: String, teamId: String) async throws
}

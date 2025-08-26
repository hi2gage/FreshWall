import Foundation

public protocol InviteRepository {
    func createInviteCode(teamId: String, createdBy: String) async throws -> String
    func validateInviteCode(_ code: String) async throws -> InviteCodeInfo
    func joinTeamWithCode(_ code: String, userId: String, userName: String, userEmail: String) async throws
}

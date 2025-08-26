import Foundation

public struct InviteCodeInfo: Codable, Sendable {
    public let teamId: String
    public let teamName: String

    public init(teamId: String, teamName: String) {
        self.teamId = teamId
        self.teamName = teamName
    }
}

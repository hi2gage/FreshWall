import Foundation

public struct Team: Codable, Sendable {
    public let id: String
    public let name: String
    public let teamCode: String
    public let createdAt: Date

    public init(id: String, name: String, teamCode: String, createdAt: Date) {
        self.id = id
        self.name = name
        self.teamCode = teamCode
        self.createdAt = createdAt
    }
}

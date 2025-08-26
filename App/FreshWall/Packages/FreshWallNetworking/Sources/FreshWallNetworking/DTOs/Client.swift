import Foundation

// MARK: - Client

public struct Client: Codable, Sendable {
    public let id: String
    public let name: String
    public let notes: String?
    public let isDeleted: Bool
    public let deletedAt: Date?
    public let createdAt: Date
    public let lastIncidentAt: Date

    public init(
        id: String,
        name: String,
        notes: String? = nil,
        isDeleted: Bool = false,
        deletedAt: Date? = nil,
        createdAt: Date,
        lastIncidentAt: Date
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.isDeleted = isDeleted
        self.deletedAt = deletedAt
        self.createdAt = createdAt
        self.lastIncidentAt = lastIncidentAt
    }
}

// MARK: - ClientCreate

public struct ClientCreate: Sendable {
    public let name: String
    public let notes: String?

    public init(name: String, notes: String? = nil) {
        self.name = name
        self.notes = notes
    }
}

// MARK: - ClientUpdate

public struct ClientUpdate: Sendable {
    public let name: String?
    public let notes: String?

    public init(name: String? = nil, notes: String? = nil) {
        self.name = name
        self.notes = notes
    }
}

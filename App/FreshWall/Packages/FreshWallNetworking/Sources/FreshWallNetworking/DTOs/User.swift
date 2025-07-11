import Foundation

// MARK: - User

public struct User: Codable, Sendable {
    public let id: String
    public let displayName: String
    public let email: String
    public let role: UserRole
    public let isDeleted: Bool
    public let deletedAt: Date?

    public init(
        id: String,
        displayName: String,
        email: String,
        role: UserRole,
        isDeleted: Bool = false,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.role = role
        self.isDeleted = isDeleted
        self.deletedAt = deletedAt
    }
}

// MARK: - UserUpdate

public struct UserUpdate: Sendable {
    public let displayName: String?
    public let role: UserRole?

    public init(displayName: String? = nil, role: UserRole? = nil) {
        self.displayName = displayName
        self.role = role
    }
}

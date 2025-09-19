import Foundation

// MARK: - InviteCodeResponseDTO

/// Raw response from Firebase generateInviteCode function
struct InviteCodeResponseDTO: Codable {
    let code: String
    let expiresAt: FirebaseTimestamp
    let joinUrl: String
    let teamId: String
    let role: String
    let maxUses: Int
}

// MARK: - InviteCode

/// Client-side model for invite codes with computed properties
struct InviteCode {
    let code: String
    let expiresAt: Date
    let joinUrl: String
    let teamId: String
    let role: UserRole
    let maxUses: Int

    init(
        code: String,
        expiresAt: Date,
        joinUrl: String,
        teamId: String,
        role: UserRole,
        maxUses: Int
    ) {
        self.code = code
        self.expiresAt = expiresAt
        self.joinUrl = joinUrl
        self.teamId = teamId
        self.role = role
        self.maxUses = maxUses
    }

    /// Initialize from Firebase DTO
    init(from dto: InviteCodeResponseDTO) {
        self.code = dto.code
        self.expiresAt = dto.expiresAt.date
        self.joinUrl = dto.joinUrl
        self.teamId = dto.teamId
        self.role = UserRole(rawValue: dto.role) ?? .fieldWorker
        self.maxUses = dto.maxUses
    }

    /// Formatted expiration date for display
    var formattedExpirationDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: expiresAt)
    }

    /// Days until expiration
    var daysUntilExpiration: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day ?? 0
    }

    /// Whether the invite code is still valid
    var isValid: Bool {
        expiresAt > Date()
    }

    /// Share message with proper formatting
    var shareMessage: String {
        """
        Join our graffiti removal team on FreshWall!

        Sign up link: \(joinUrl)

        """
    }
}

// MARK: - FirebaseTimestamp

/// Helper struct to decode Firebase Timestamp from Cloud Functions
struct FirebaseTimestamp: Codable {
    let seconds: TimeInterval
    let nanoseconds: Int

    var date: Date {
        Date(timeIntervalSince1970: seconds)
    }

    enum CodingKeys: String, CodingKey {
        case seconds = "_seconds"
        case nanoseconds = "_nanoseconds"
    }
}

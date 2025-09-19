@preconcurrency import FirebaseFunctions
import Foundation

// MARK: - InviteCodeGenerating

protocol InviteCodeGenerating: Sendable {
    func generateInviteCode(teamId: String, role: UserRole, maxUses: Int) async throws -> InviteCode
}

// MARK: - MockInviteCodeGenerator

struct MockInviteCodeGenerator: InviteCodeGenerating {
    func generateInviteCode(teamId _: String, role _: UserRole, maxUses _: Int) async throws -> InviteCode {
        InviteCode(
            code: "A5883E",
            expiresAt: .distantFuture,
            joinUrl: "https://freshwall.app/more/join?teamCode=A5883E",
            teamId: "A5883E",
            role: .manager,
            maxUses: 10
        )
    }
}

// MARK: - InviteCodeService

struct InviteCodeService: InviteCodeGenerating {
    private let functions = Functions.functions()

    init() {}

    func generateInviteCode(
        teamId: String,
        role: UserRole = .fieldWorker,
        maxUses: Int = 10
    ) async throws -> InviteCode {
        let result = try await functions.httpsCallable("generateInviteCode").call([
            "teamId": teamId,
            "role": role.rawValue,
            "maxUses": maxUses,
        ])

        guard let data = result.data as? [String: Any] else {
            throw InviteCodeError.invalidResponse("No data received from generateInviteCode")
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let dto = try JSONDecoder().decode(InviteCodeResponseDTO.self, from: jsonData)
            return InviteCode(from: dto)
        } catch {
            throw InviteCodeError.parsingError("Failed to parse invite code response: \(error.localizedDescription)")
        }
    }
}

// MARK: - InviteCodeError

enum InviteCodeError: LocalizedError {
    case invalidResponse(String)
    case parsingError(String)
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case let .invalidResponse(message):
            "Invalid response: \(message)"
        case let .parsingError(message):
            "Parsing error: \(message)"
        case let .networkError(message):
            "Network error: \(message)"
        }
    }
}

@preconcurrency import FirebaseFunctions
import Foundation

// MARK: - InviteCodeGenerating

protocol InviteCodeGenerating: Sendable {
    func generateInviteCode(role: UserRole, maxUses: Int) async throws -> String
}

// MARK: - InviteCodeService

struct InviteCodeService: InviteCodeGenerating {
    private let functions = Functions.functions()

    init() {}

    func generateInviteCode(role: UserRole = .member, maxUses: Int = 10) async throws -> String {
        let result = try await functions.httpsCallable("generateInviteCode").call([
            "role": role.rawValue,
            "maxUses": maxUses,
        ])
        guard let data = result.data as? [String: Any], let code = data["code"] as? String else {
            throw NSError(
                domain: "InviteCodeService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response from generateInviteCode"]
            )
        }

        return code
    }
}

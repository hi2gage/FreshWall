@preconcurrency import FirebaseFunctions
import Foundation

protocol InviteCodeGenerating: Sendable {
    func generateInviteCode(role: UserRole, maxUses: Int) async throws -> String
}

struct InviteCodeService: InviteCodeGenerating {
    private let functions = Functions.functions()

    init() {
        #if DEBUG
            Functions.functions().useEmulator(withHost: "localhost", port: 5001)
        #endif
    }

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

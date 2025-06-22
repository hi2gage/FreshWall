import Foundation
import Observation

@MainActor
@Observable
final class InviteMemberViewModel {
    var code: String?
    private let service: InviteCodeGenerating

    init(service: InviteCodeGenerating) {
        self.service = service
    }

    func generate() async {
        do {
            code = try await service.generateInviteCode(role: .member, maxUses: 10)
        } catch {
            code = nil
        }
    }

    var shareMessage: String {
        """
        Join our graffiti removal team on FreshWall!

        1. Download the app: https://apps.apple.com/us/app/freshwall/id123456789
        2. Use this code when signing up: \(code ?? "")
        """
    }
}

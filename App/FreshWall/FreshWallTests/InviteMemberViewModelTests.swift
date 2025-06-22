@testable import FreshWall
import Testing

@MainActor
struct InviteMemberViewModelTests {
    final actor MockService: InviteCodeGenerating {
        func generateInviteCode(role _: UserRole, maxUses _: Int) async throws -> String { "ABC123" }
    }

    @Test func shareMessageContainsCode() async throws {
        let vm = InviteMemberViewModel(service: MockService())
        await vm.generate()
        #expect(vm.shareMessage.contains("ABC123"))
    }
}

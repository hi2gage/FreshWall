@testable import FreshWall

final class MemberServiceProtocolMock: MemberServiceProtocol {
    func fetchMembers() async throws -> [Member] {
        []
    }

    func addMember(_: AddMemberInput) async throws {
        // No-op implementation for testing
    }
}

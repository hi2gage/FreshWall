@testable import FreshWall
import Testing

@MainActor
struct MembersListViewModelTests {
    final class MockService: MemberServiceProtocol {
        func fetchMembers() async throws -> [Member] { [] }
        func addMember(_: AddMemberInput) async throws {}
    }

    @Test func groupingByRole() {
        let service = MockService()
        let vm = MembersListViewModel(service: service, currentUserId: "1")
        vm.members = [
            Member(id: "1", displayName: "Alice", email: "a", role: .lead, isDeleted: false, deletedAt: nil),
            Member(id: "2", displayName: "Bob", email: "b", role: .member, isDeleted: false, deletedAt: nil),
        ]
        vm.groupOption = .role
        let groups = vm.groupedMembers()
        #expect(groups.count == 2)
        #expect(groups.first?.title == "Lead")
    }

    @Test func defaultSortPinsCurrentUser() {
        let service = MockService()
        let vm = MembersListViewModel(service: service, currentUserId: "2")
        vm.members = [
            Member(id: "1", displayName: "A", email: "", role: .member, isDeleted: false, deletedAt: nil),
            Member(id: "2", displayName: "B", email: "", role: .member, isDeleted: false, deletedAt: nil),
        ]
        let sorted = vm.sortedMembers()
        #expect(sorted.first?.id == "2")
    }

    @Test func userSortRemovesPin() {
        let service = MockService()
        let vm = MembersListViewModel(service: service, currentUserId: "2")
        vm.members = [
            Member(id: "1", displayName: "A", email: "", role: .lead, isDeleted: false, deletedAt: nil),
            Member(id: "2", displayName: "B", email: "", role: .member, isDeleted: false, deletedAt: nil),
        ]
        vm.sort.toggleOrSelect(.role)
        let sorted = vm.sortedMembers()
        #expect(sorted.first?.id == "1")
    }
}

import Observation

/// ViewModel driving the MembersListView.
@Observable
final class MembersListViewModel {
    /// Array of team members to display.
    var members: [User] = []
    private let service: MemberService

    /// Initializes with a MemberService.
    init(service: MemberService) {
        self.service = service
    }

    /// Loads members from the service.
    func loadMembers() async {
        await service.fetchMembers()
        members = service.members
    }
}
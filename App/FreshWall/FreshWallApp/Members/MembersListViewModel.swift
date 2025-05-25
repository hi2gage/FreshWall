import Observation

/// ViewModel responsible for member list presentation and data operations.
@MainActor
@Observable
final class MembersListViewModel {
    /// Team members fetched from the service.
    var members: [User] = []
    private let service: MemberServiceProtocol

    /// Initializes the view model with a service conforming to `MemberServiceProtocol`.
    init(service: MemberServiceProtocol) {
        self.service = service
    }

    /// Loads members from the service.
    func loadMembers() async {
        members = await (try? service.fetchMembers()) ?? []
    }
}

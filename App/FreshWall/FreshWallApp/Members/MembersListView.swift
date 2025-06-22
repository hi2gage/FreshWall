@preconcurrency import FirebaseFirestore
import SwiftUI

/// A view displaying a list of team members.
struct MembersListView: View {
    let service: MemberServiceProtocol
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: MembersListViewModel

    /// Initializes the view with a member service implementing `MemberServiceProtocol`.
    init(service: MemberServiceProtocol) {
        self.service = service
        _viewModel = State(wrappedValue: MembersListViewModel(service: service))
    }

    var body: some View {
        GenericListView(
            items: viewModel.members,
            title: "Members",
            routerDestination: { member in .memberDetail(member: member) },
            content: { member in
                MemberListCell(member: member)
            },
            plusButtonAction: {
                routerPath.push(.inviteMember)
            },
            refreshAction: {
                await viewModel.loadMembers()
            }
        )
        .task {
            await viewModel.loadMembers()
        }
    }
}

#Preview {
    let userService = UserService()
    let firestore = Firestore.firestore()
    let service = MemberService(
        firestore: firestore,
        session: .init(
            userId: "",
            displayName: "",
            teamId: ""
        )
    )
    FreshWallPreview {
        NavigationStack {
            MembersListView(service: service)
        }
    }
}

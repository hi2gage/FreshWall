import SwiftUI

/// A view displaying a list of team members.
struct MembersListView: View {
    let userService: UserService
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: MembersListViewModel

    init(userService: UserService) {
        self.userService = userService
        _viewModel = State(wrappedValue: MembersListViewModel(service: MemberService(userService: userService)))
    }

    var body: some View {
        List {
            if viewModel.members.isEmpty {
                Text("No members available.")
            } else {
                ForEach(viewModel.members) { member in
                    Button(member.displayName) {
                        if let id = member.id {
                            routerPath.push(.memberDetail(id: id))
                        }
                    }
                }
            }
        }
        .navigationTitle("Members")
        .task {
            await viewModel.loadMembers()
        }
    }
}

struct MembersListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MembersListView(userService: UserService())
        }
    }
}

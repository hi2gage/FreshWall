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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    routerPath.push(.addMember)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            await viewModel.loadMembers()
        }
    }
}

#Preview {
    let userService = UserService()
    let firestore = Firestore.firestore()
    let service = MemberService(firestore: firestore, session: .init(userId: "", teamId: ""))
    FreshWallPreview {
        NavigationStack {
            MembersListView(service: service)
        }
    }
}

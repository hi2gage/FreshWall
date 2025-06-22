@preconcurrency import FirebaseFirestore
import SwiftUI

/// A view displaying a list of team members.
struct MembersListView: View {
    let service: MemberServiceProtocol
    let currentUserId: String
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: MembersListViewModel

    /// Initializes the view with a member service implementing `MemberServiceProtocol`.
    init(service: MemberServiceProtocol, currentUserId: String) {
        self.service = service
        self.currentUserId = currentUserId
        _viewModel = State(
            wrappedValue: MembersListViewModel(
                service: service,
                currentUserId: currentUserId
            )
        )
    }

    var body: some View {
        GenericGroupableListView(
            groups: viewModel.groupedMembers(),
            title: "Members",
            groupOption: $viewModel.groupOption,
            routerDestination: { member in .memberDetail(member: member) },
            content: { member in
                MemberListCell(member: member)
            },
            plusButtonAction: {
                routerPath.push(.inviteMember)
            },
            refreshAction: {
                await viewModel.loadMembers()
            },
            menu: { collapsedGroups in
                Menu {
                    groupingMenu(
                        groups: viewModel.groupedMembers(),
                        collapsedGroups: collapsedGroups
                    )
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        )
        .onChange(of: viewModel.sort) { _, _ in viewModel.userSelectedSort = true }
        .task {
            await viewModel.loadMembers()
        }
    }

    @ViewBuilder
    private func groupingMenu(
        groups: [(title: String?, items: [Member])],
        collapsedGroups: Binding<Set<Int>>
    ) -> some View {
        Text("Group By")
            .font(.caption)
            .foregroundColor(.secondary)

        Picker("Group By", selection: $viewModel.groupOption) {
            Text("None").tag(MemberGroupOption?.none)
            ForEach(MemberGroupOption.allCases, id: \.self) { option in
                Text(option.rawValue).tag(Optional.some(option))
            }
        }

        Text("Sort By")
            .font(.caption)
            .foregroundColor(.secondary)

        if viewModel.groupOption == nil {
            SortButton(for: .alphabetical, sort: $viewModel.sort)
            SortButton(for: .role, sort: $viewModel.sort)
        } else {
            SortButton(for: .alphabetical, sort: $viewModel.sort)
            collapseToggleButton(groups: groups, collapsedGroups: collapsedGroups)
        }
    }

    @ViewBuilder
    private func collapseToggleButton(
        groups: [(title: String?, items: [Member])],
        collapsedGroups: Binding<Set<Int>>
    ) -> some View {
        let allCollapsed = collapsedGroups.wrappedValue.count == groups.count

        Button {
            if allCollapsed {
                collapsedGroups.wrappedValue.removeAll()
            } else {
                collapsedGroups.wrappedValue = Set(groups.indices)
            }
        } label: {
            Label(
                allCollapsed ? "Uncollapse All" : "Collapse All",
                systemImage: allCollapsed ? "chevron.down" : "chevron.right"
            )
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
            MembersListView(
                service: service,
                currentUserId: ""
            )
        }
    }
}

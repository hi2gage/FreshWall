import SwiftUI

/// A generic view for displaying items grouped into sections with a menu for selecting a grouping option.
struct GenericGroupableListView<
    Item: Identifiable,
    Destination: Hashable,
    GroupOption: CaseIterable & Hashable & RawRepresentable,
    Content: View,
    MenuContent: View
>: View where GroupOption.RawValue == String {
    /// Groups of items along with optional section titles.
    var groups: [(title: String?, items: [Item])]
    /// Title used in the navigation bar.
    var title: String
    /// Currently selected grouping option (nil means no grouping).
    @Binding var groupOption: GroupOption?
    /// Produces a navigation destination for a given item.
    var destination: (Item) -> Destination
    /// Creates the content view for a given item.
    var content: (Item) -> Content

    let plusButtonAction: @MainActor () -> Void
    let refreshAction: @MainActor () async -> Void
    @ViewBuilder var menu: (_ collapsedGroups: Binding<Set<Int>>) -> MenuContent

    /// Tracks which groups are collapsed by index when grouping is enabled.
    @State private var collapsedGroups: Set<Int> = []

    init(
        groups: [(title: String?, items: [Item])],
        title: String,
        groupOption: Binding<GroupOption?>,
        destination: @escaping (Item) -> Destination,
        content: @escaping (Item) -> Content,
        plusButtonAction: @escaping @MainActor () -> Void,
        refreshAction: @escaping @MainActor () async -> Void = {},
        @ViewBuilder menu: @escaping (_ collapsedGroups: Binding<Set<Int>>) -> MenuContent = { _ in EmptyView() }
    ) {
        self.groups = groups
        self.title = title
        _groupOption = groupOption
        self.destination = destination
        self.content = content
        self.plusButtonAction = plusButtonAction
        self.refreshAction = refreshAction
        self.menu = menu
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(groups.indices, id: \.self) { index in
                    let group = groups[index]
                    if let title = group.title, groups.count > 1 {
                        Button {
                            withAnimation { toggleCollapse(index) }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(collapsedGroups.contains(index) ? 0 : 90))
                                    .animation(.easeInOut(duration: 0.2), value: collapsedGroups)
                                    .frame(width: 16, alignment: .leading)
                                Text(title)
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                    } else if let title = group.title {
                        Text(title)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }

                    if !collapsedGroups.contains(index) {
                        VStack(spacing: 16) {
                            ForEach(group.items) { item in
                                NavigationLink(value: destination(item)) {
                                    content(item)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                        .transition(.opacity)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: collapsedGroups)
        }
        .refreshable { await refreshAction() }
        .scrollIndicators(.hidden)
        .navigationTitle(title)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                menu($collapsedGroups)
                Button { plusButtonAction() } label: { Image(systemName: "plus") }
            }
        }
        .onChange(of: groupOption) { _, _ in
            collapsedGroups.removeAll()
        }
    }

    private func toggleCollapse(_ index: Int) {
        if collapsedGroups.contains(index) {
            collapsedGroups.remove(index)
        } else {
            collapsedGroups.insert(index)
        }
    }
}

extension GenericGroupableListView where Destination == RouterDestination {
    init(
        groups: [(title: String?, items: [Item])],
        title: String,
        groupOption: Binding<GroupOption?>,
        routerDestination: @escaping (Item) -> RouterDestination,
        content: @escaping (Item) -> Content,
        plusButtonAction: @escaping @MainActor () -> Void,
        refreshAction: @escaping @MainActor () async -> Void = {},
        @ViewBuilder menu: @escaping (_ collapsedGroups: Binding<Set<Int>>) -> MenuContent = { _ in EmptyView() }
    ) {
        self.init(
            groups: groups,
            title: title,
            groupOption: groupOption,
            destination: routerDestination,
            content: content,
            plusButtonAction: plusButtonAction,
            refreshAction: refreshAction,
            menu: menu
        )
    }
}

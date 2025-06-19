import SwiftUI

/// A generic view for displaying items grouped into sections with a context menu for selecting a grouping option.
struct GenericGroupableListView<
    Item: Identifiable,
    GroupOption: CaseIterable & Hashable & RawRepresentable,
    Content: View
>: View where GroupOption.RawValue == String {
    /// Groups of items along with optional section titles.
    var groups: [(title: String?, items: [Item])]
    /// Title used in the navigation bar.
    var title: String
    /// Currently selected grouping option.
    @Binding var groupOption: GroupOption
    /// Field used when sorting items when grouping is `.none`.
    @Binding var sortField: IncidentSortField
    /// Indicates whether sorting is ascending.
    @Binding var isAscending: Bool
    /// Produces a navigation destination for a given item.
    var destination: (Item) -> RouterDestination
    /// Creates the content view for a given item.
    var content: (Item) -> Content

    let plusButtonAction: @MainActor () -> Void

    /// Tracks which groups are collapsed by index when grouping is enabled.
    @State private var collapsedGroups: Set<Int> = []

    init(
        groups: [(title: String?, items: [Item])],
        title: String,
        groupOption: Binding<GroupOption>,
        sortField: Binding<IncidentSortField>,
        isAscending: Binding<Bool>,
        destination: @escaping (Item) -> RouterDestination,
        content: @escaping (Item) -> Content,
        plusButtonAction: @escaping @MainActor () -> Void
    ) {
        self.groups = groups
        self.title = title
        _groupOption = groupOption
        _sortField = sortField
        _isAscending = isAscending
        self.destination = destination
        self.content = content
        self.plusButtonAction = plusButtonAction
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
                                Image(systemName: collapsedGroups.contains(index) ? "chevron.right" : "chevron.down")
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
                        ForEach(group.items) { item in
                            NavigationLink(value: destination(item)) {
                                content(item)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(Array(GroupOption.allCases), id: \.self) { option in
                        Button {
                            groupOption = option
                        } label: {
                            Label {
                                Text(option.rawValue)
                            } icon: {
                                if option == groupOption {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }

                    if groupOption == .none {
                        Button {
                            if sortField == .alphabetical {
                                isAscending.toggle()
                            } else {
                                sortField = .alphabetical
                                isAscending = true
                            }
                        } label: {
                            let arrow = sortField == .alphabetical ? (isAscending ? "arrow.up" : "arrow.down") : ""
                            Label("Alphabetical", systemImage: arrow)
                        }

                        Button {
                            if sortField == .date {
                                isAscending.toggle()
                            } else {
                                sortField = .date
                                isAscending = true
                            }
                        } label: {
                            let arrow = sortField == .date ? (isAscending ? "arrow.up" : "arrow.down") : ""
                            Label("By Date", systemImage: arrow)
                        }
                    } else {
                        Menu("Order") {
                            Button { isAscending = true } label: {
                                Label("Ascending", systemImage: isAscending ? "checkmark" : "")
                            }
                            Button { isAscending = false } label: {
                                Label("Descending", systemImage: isAscending ? "" : "checkmark")
                            }
                        }
                    }
                    if groupOption != .none {
                        let allCollapsed = collapsedGroups.count == groups.count
                        Button {
                            if allCollapsed {
                                collapsedGroups.removeAll()
                            } else {
                                collapsedGroups = Set(groups.indices)
                            }
                        } label: {
                            Label(allCollapsed ? "Uncollapse All" : "Collapse All",
                                  systemImage: allCollapsed ? "chevron.down" : "chevron.right")
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
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

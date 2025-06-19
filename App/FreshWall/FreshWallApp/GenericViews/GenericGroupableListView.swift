import SwiftUI

/// A generic view for displaying items grouped into sections with a context menu for selecting a grouping option.
struct GenericGroupableListView<Item: Identifiable, GroupOption: CaseIterable & Hashable & RawRepresentable, Content: View>: View where GroupOption.RawValue == String {
    /// Groups of items along with optional section titles.
    var groups: [(title: String?, items: [Item])]
    /// Title used in the navigation bar.
    var title: String
    /// Currently selected grouping option.
    @Binding var groupOption: GroupOption
    /// Produces a navigation destination for a given item.
    var destination: (Item) -> RouterDestination
    /// Creates the content view for a given item.
    var content: (Item) -> Content

    let plusButtonAction: @MainActor () -> Void

    init(
        groups: [(title: String?, items: [Item])],
        title: String,
        groupOption: Binding<GroupOption>,
        destination: @escaping (Item) -> RouterDestination,
        content: @escaping (Item) -> Content,
        plusButtonAction: @escaping @MainActor () -> Void
    ) {
        self.groups = groups
        self.title = title
        _groupOption = groupOption
        self.destination = destination
        self.content = content
        self.plusButtonAction = plusButtonAction
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(groups.indices, id: \.self) { index in
                    let group = groups[index]
                    if let title = group.title {
                        Text(title)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
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
        .scrollIndicators(.hidden)
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(Array(GroupOption.allCases), id: \.self) { option in
                        Button {
                            groupOption = option
                        } label: {
                            Label(option.rawValue, systemImage: option == groupOption ? "checkmark" : "")
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
    }
}

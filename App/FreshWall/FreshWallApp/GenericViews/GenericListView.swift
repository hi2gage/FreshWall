import SwiftUI

struct GenericListView<
    Item: Identifiable,
    Destination: Hashable,
    Content: View,
    MenuContent: View
>: View {
    var items: [Item]
    var title: String
    var destination: (Item) -> Destination
    var content: (Item) -> Content

    let plusButtonAction: @MainActor () -> Void
    let refreshAction: @MainActor () async -> Void
    @ViewBuilder var menu: () -> MenuContent

    init(
        items: [Item],
        title: String,
        destination: @escaping (Item) -> Destination,
        content: @escaping (Item) -> Content,
        plusButtonAction: @escaping @MainActor () -> Void,
        refreshAction: @escaping @MainActor () async -> Void,
        @ViewBuilder menu: @escaping () -> MenuContent = { EmptyView() }
    ) {
        self.items = items
        self.title = title
        self.destination = destination
        self.content = content
        self.plusButtonAction = plusButtonAction
        self.refreshAction = refreshAction
        self.menu = menu
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(items) { item in
                    NavigationLink(value: destination(item)) {
                        content(item)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
        }
        .refreshable { await refreshAction() }
        .scrollIndicators(.hidden)
        .navigationTitle(title)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                menu()
                Button {
                    plusButtonAction()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

extension GenericListView where Destination == RouterDestination {
    init(
        items: [Item],
        title: String,
        routerDestination: @escaping (Item) -> RouterDestination,
        content: @escaping (Item) -> Content,
        plusButtonAction: @escaping @MainActor () -> Void,
        refreshAction: @escaping @MainActor () async -> Void = {},
        @ViewBuilder menu: @escaping () -> MenuContent = { EmptyView() }
    ) {
        self.init(
            items: items,
            title: title,
            destination: routerDestination,
            content: content,
            plusButtonAction: plusButtonAction,
            refreshAction: refreshAction,
            menu: menu
        )
    }
}

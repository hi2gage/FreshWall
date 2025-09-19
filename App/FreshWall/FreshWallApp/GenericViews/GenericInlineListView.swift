import SwiftUI

// MARK: - GenericInlineListView

/// A simplified inline list view for displaying items within a Section, based on GenericGroupableListView
struct GenericInlineListView<
    Item: Identifiable,
    Destination: Hashable,
    Content: View
>: View {
    /// Items to display
    let items: [Item]
    /// Section title
    let title: String
    /// Loading state
    let isLoading: Bool
    /// Empty state message
    let emptyMessage: String
    /// Produces a navigation destination for a given item
    let destination: (Item) -> Destination
    /// Creates the content view for a given item
    let content: (Item) -> Content
    /// Router path for navigation
    @Environment(RouterPath.self) private var routerPath

    init(
        items: [Item],
        title: String,
        isLoading: Bool = false,
        emptyMessage: String = "No items found.",
        destination: @escaping (Item) -> Destination,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.title = title
        self.isLoading = isLoading
        self.emptyMessage = emptyMessage
        self.destination = destination
        self.content = content
    }

    var body: some View {
        Section(header: Text(headerText)) {
            if isLoading {
                GenericSkeletonRows()
            } else if items.isEmpty {
                Text(emptyMessage)
                    .italic()
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 16) {
                    ForEach(items) { item in
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

    private var headerText: String {
        if isLoading {
            "\(title) (...)"
        } else {
            "\(title) (\(items.count))"
        }
    }
}

// MARK: - GenericSkeletonRows

/// Generic skeleton placeholder rows for loading states
struct GenericSkeletonRows: View {
    let count: Int

    init(count: Int = 3) {
        self.count = count
    }

    var body: some View {
        ForEach(0 ..< count, id: \.self) { _ in
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 20)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 14)
                        .frame(maxWidth: 120, alignment: .leading)
                }

                Spacer()

                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 8, height: 12)
            }
            .padding(.vertical, 2)
        }
    }
}

// MARK: - RouterDestination Extension

extension GenericInlineListView where Destination == RouterDestination {
    init(
        items: [Item],
        title: String,
        isLoading: Bool = false,
        emptyMessage: String = "No items found.",
        routerDestination: @escaping (Item) -> RouterDestination,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.init(
            items: items,
            title: title,
            isLoading: isLoading,
            emptyMessage: emptyMessage,
            destination: routerDestination,
            content: content
        )
    }
}

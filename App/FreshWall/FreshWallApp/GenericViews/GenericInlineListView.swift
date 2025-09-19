import Shimmer
import SwiftUI

// MARK: - GenericInlineButtonListView

/// Button-based navigation version that avoids NavigationLink chevrons
struct GenericInlineButtonListView<
    Item: Identifiable,
    Content: View
>: View {
    let items: [Item]
    let title: String
    let isLoading: Bool
    let emptyMessage: String
    let onItemTap: (Item) -> Void
    let content: (Item) -> Content

    init(
        items: [Item],
        title: String,
        isLoading: Bool = false,
        emptyMessage: String = "No items found.",
        onItemTap: @escaping (Item) -> Void,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.title = title
        self.isLoading = isLoading
        self.emptyMessage = emptyMessage
        self.onItemTap = onItemTap
        self.content = content
    }

    var body: some View {
        Section(header: Text(headerText)) {
            if isLoading {
                GenericSkeletonRows()
                    .shimmering()
            } else if items.isEmpty {
                Text(emptyMessage)
                    .italic()
                    .foregroundColor(.secondary)
            } else {
                LazyVStack {
                    ForEach(items) { item in
                        Button {
                            onItemTap(item)
                        } label: {
                            content(item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
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
            }
            .padding(.vertical, 2)
        }
    }
}

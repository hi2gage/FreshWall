@testable import FreshWall
import SwiftUI
import Testing

struct GenericGroupableListViewTests {
    struct Item: Identifiable { let id: Int }
    enum Option: String, CaseIterable { case none }

    @Test func initDoesNotCrash() {
        let groups = [(title: "Title", items: [Item(id: 1)])]
        _ = GenericGroupableListView(
            groups: groups,
            title: "Test",
            groupOption: .constant(.none),
            sortField: .constant(.date),
            isAscending: .constant(true),
            destination: { _ in .clientsList },
            content: { _ in EmptyView() },
            plusButtonAction: {}
        )
    }
}

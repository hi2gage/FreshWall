import SwiftUI

struct GenericListView<Item: Identifiable, Content: View>: View {
    var items: [Item]
    var title: String
    var destination: (Item) -> RouterDestination
    var content: (Item) -> Content

    let plusButtonAction: @MainActor () -> Void

    init(
        items: [Item],
        title: String,
        destination: @escaping (Item) -> RouterDestination,
        content: @escaping (Item) -> Content,
        plusButtonAction: @escaping @MainActor () -> Void
    ) {
        self.items = items
        self.title = title
        self.destination = destination
        self.content = content
        self.plusButtonAction = plusButtonAction
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
        .scrollIndicators(.hidden)
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    plusButtonAction()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
//        .foregroundStyle(Color.brandTextSecondary)
//        .toolbar {
//            ToolbarItem(placement: .principal) {}
//            ToolbarItem(placement: .topBarLeading) {
//                Menu {
//                    Picker("Sort by", selection: toolbarPickerSelection) {
//                        Text("Brews").tag(MainScreen.brews)
//                        Text("Recipes").tag(MainScreen.recipes)
//                    }
//                } label: {
//                    HStack {
//                        Text(title.capitalized)
//                            .font(.largeTitle)
//                            .bold()
//                        Image(systemName: "chevron.down")
//                    }
//                    .padding(.bottom)
//                }
//            }
//        }
    }
}

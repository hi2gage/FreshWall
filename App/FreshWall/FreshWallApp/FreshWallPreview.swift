import SwiftUI

/// A container for SwiftUI previews that injects a RouterPath environment instance.
struct FreshWallPreview<Content: View>: View {
    private let content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .environment(RouterPath())
    }
}

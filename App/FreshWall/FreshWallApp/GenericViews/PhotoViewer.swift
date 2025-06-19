import SwiftUI

/// Represents either a remote or local image for photo viewing.
enum PhotoSource: Hashable, Sendable {
    case uiImage(UIImage)
    case url(String)
}

/// Full screen, swipeable viewer for incident photos.
struct PhotoViewer: View {
    let sources: [PhotoSource]
    @Binding var index: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView(selection: $index) {
            ForEach(sources.indices, id: \.self) { idx in
                viewer(for: sources[idx])
                    .tag(idx)
                    .ignoresSafeArea()
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Color.black)
        .onTapGesture { dismiss() }
    }

    @ViewBuilder
    private func viewer(for source: PhotoSource) -> some View {
        switch source {
        case let .uiImage(image):
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        case let .url(string):
            AsyncImage(url: URL(string: string)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case let .success(image):
                    image.resizable().scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    PhotoViewer(
        sources: [.url("https://example.com/photo.jpg")],
        index: .constant(0)
    )
}

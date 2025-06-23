import SwiftUI

/// A horizontally scrollable carousel of photos that can launch a full-screen photo viewer.
struct PhotoCarousel: View {
    let photos: [IncidentPhoto]

    @State private var viewerContext: PhotoViewerContext?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(photos) { photo in
                    Button {
                        viewerContext = PhotoViewerContext(photos: photos, selectedPhoto: photo)
                    } label: {
                        AsyncImage(url: URL(string: photo.url)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            case let .success(image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(height: 120)
        .fullScreenCover(item: $viewerContext) { context in
            PhotoViewer(photos: context.photos, selectedPhoto: context.selectedPhoto)
        }
    }
}

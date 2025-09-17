import SwiftUI

/// A horizontally scrollable carousel of photos that can launch a full-screen photo viewer.
struct PhotoCarousel: View {
    let photos: [IncidentPhoto]

    @Environment(RouterPath.self) private var routerPath

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(photos) { photo in
                    Button {
                        let context = PhotoViewerContext(photos: photos, selectedPhoto: photo)
                        routerPath.push(.photoViewer(context: context))
                    } label: {
                        AsyncImage(url: URL(string: photo.thumbnailUrl ?? photo.url)) { phase in
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
    }
}

import SwiftUI

/// Full screen photo viewer with paging and pinch-to-zoom support.
struct PhotoViewer: View {
    let photos: [IncidentPhoto]
    @State private var index: Int
    @Environment(\.dismiss) private var dismiss

    init(photos: [IncidentPhoto], selectedPhoto: IncidentPhoto?) {
        self.photos = photos
        _index = State(initialValue: Self.initialIndex(photos: photos, selectedPhoto: selectedPhoto))
    }

    /// Calculate the starting index for the viewer.
    /// - Parameters:
    ///   - photos: All available photos.
    ///   - selectedPhoto: The photo the user tapped on.
    /// - Returns: Index of `selectedPhoto` or `0` if not found.
    static func initialIndex(photos: [IncidentPhoto], selectedPhoto: IncidentPhoto?) -> Int {
        if let selectedPhoto, let idx = photos.firstIndex(of: selectedPhoto) {
            return idx
        }
        return 0
    }

    var body: some View {
        TabView(selection: $index) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { idx, photo in
                AsyncImage(url: URL(string: photo.url)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                    case let .success(image):
                        ZoomableImage(image: image)
                            .tag(idx)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                            .tag(idx)
                    @unknown default:
                        EmptyView()
                            .tag(idx)
                    }
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Color.black.ignoresSafeArea())
        .onTapGesture { dismiss() }
    }
}

/// Image that supports pinch and drag to zoom.
private struct ZoomableImage: View {
    var image: Image
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = CGSize(
                            width: lastOffset.width + value.translation.width,
                            height: lastOffset.height + value.translation.height
                        )
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = lastScale * value
                    }
                    .onEnded { _ in
                        lastScale = scale
                    }
            )
            .animation(.easeInOut, value: scale)
    }
}

#Preview {
    let photos = [
        IncidentPhoto(id: "1", url: "https://via.placeholder.com/600", captureDate: nil, location: nil),
        IncidentPhoto(id: "2", url: "https://via.placeholder.com/600/EEE", captureDate: nil, location: nil)
    ]
    return FreshWallPreview {
        PhotoViewer(photos: photos, selectedPhoto: photos.first)
    }
}

import SwiftUI

// MARK: - PhotoViewer

/// Full screen photo viewer with paging and pinch-to-zoom support.
struct PhotoViewer: View {
    let photos: [IncidentPhoto]
    @State private var index: Int
    @State private var isZoomed = false

    init(photos: [IncidentPhoto], selectedPhoto: IncidentPhoto?) {
        self.photos = photos
        _index = State(initialValue: Self.initialIndex(photos: photos, selectedPhoto: selectedPhoto))
    }

    static func initialIndex(photos: [IncidentPhoto], selectedPhoto: IncidentPhoto?) -> Int {
        if let selectedPhoto, let idx = photos.firstIndex(of: selectedPhoto) {
            return idx
        }
        return 0
    }

    var body: some View {
        TabView(selection: $index) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { idx, photo in
                ZStack {
                    AsyncImage(url: URL(string: photo.url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black)
                        case let .success(image):
                            image
                                .resizable()
                                .scaledToFit()
                                .zoomable(
                                    minZoomScale: 1,
                                    doubleTapZoomScale: 3
                                )
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    let photos = [
        IncidentPhoto(id: "1", url: "https://via.placeholder.com/600", captureDate: nil, location: nil),
        IncidentPhoto(id: "2", url: "https://via.placeholder.com/600/EEE", captureDate: nil, location: nil),
    ]
    return FreshWallPreview {
        PhotoViewer(photos: photos, selectedPhoto: photos.first)
    }
}

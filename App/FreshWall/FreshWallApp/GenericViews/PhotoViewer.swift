import Nuke
import NukeUI
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
                    if let url = URL(string: photo.url) {
                        LazyImage(url: url) { state in
                            if let image = state.image {
                                let _ = print("🖼️ [INSTANT] Photo \(idx + 1) at \(Date().timeIntervalSince1970) loaded from cache: \(url.lastPathComponent)")
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .zoomable(
                                        minZoomScale: 1,
                                        doubleTapZoomScale: 3
                                    )
                            } else if state.error != nil {
                                let _ = print("❌ [ERROR] Photo \(idx + 1) failed to load: \(url.lastPathComponent)")
                                ZStack {
                                    Color.black
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            } else {
                                let _ = print("⏳ [LOADING] Photo \(idx + 1) at \(Date().timeIntervalSince1970): \(url.lastPathComponent)")
                                ZStack {
                                    Color.black
                                    ProgressView()
                                        .tint(.white)
                                }
                            }
                        }
                        .processors([
                            ImageProcessors.Resize(width: 1000), // Decode at smaller size
                        ])
                        .priority(.veryHigh)
                    } else {
                        ZStack {
                            Color.black
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.white.opacity(0.5))
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

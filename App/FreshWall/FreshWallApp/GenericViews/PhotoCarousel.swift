import NukeUI
import os
import SwiftUI

// MARK: - PhotoCarousel

/// A horizontally scrollable carousel of photos that can launch a full-screen photo viewer.
struct PhotoCarousel: View {
    let photos: [IncidentPhoto]
    private let logger = Logger.freshWall(category: "PhotoCarousel")

    @Environment(RouterPath.self) private var routerPath

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(photos) { photo in
                    Button {
                        let context = PhotoViewerContext(photos: photos, selectedPhoto: photo)
                        routerPath.push(.photoViewer(context: context))
                    } label: {
                        if let url = URL(string: photo.thumbnailUrl ?? photo.url) {
                            LazyImage(url: url) { state in
                                if let image = state.image {
                                    let _ = logger.info("🎠 Carousel thumbnail loaded: \(url.lastPathComponent)")
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(4)
                                } else if state.error != nil {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.1))
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(width: 100, height: 100)
                                } else {
                                    // Loading state
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.2))
                                        ProgressView()
                                            .scaleEffect(0.7)
                                    }
                                    .frame(width: 100, height: 100)
                                }
                            }
                            .processors([.resize(size: CGSize(width: Constants.imageSize * 2, height: Constants.imageSize * 2))])
                            .priority(.high)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.1))
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 100, height: 100)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(height: 120)
    }
}

// MARK: - Constants

private enum Constants {
    static let imageSize: CGFloat = 84 // Increased from 80 to compensate for padding
}

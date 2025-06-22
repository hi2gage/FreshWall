import SwiftUI

/// A horizontally scrollable carousel of photos.
struct PhotoCarousel: View {
    let photos: [IncidentPhoto]
    let onSelect: (IncidentPhoto) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(photos) { photo in
                    Button {
                        onSelect(photo)
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
    }
}

#Preview {
    let photos = [
        IncidentPhoto(id: "1", url: "https://via.placeholder.com/100", captureDate: nil, location: nil),
        IncidentPhoto(id: "2", url: "https://via.placeholder.com/100/EEE", captureDate: nil, location: nil)
    ]
    return FreshWallPreview {
        PhotoCarousel(photos: photos) { _ in }
    }
}

import NukeUI
import SwiftUI

// MARK: - IncidentListCell

/// A cell view displaying summary information for an incident with optimized image loading.
struct IncidentListCell: View {
    let incident: Incident

    var body: some View {
        HStack(alignment: .top, spacing: Constants.cellSpacing) {
            if let urlString = incident.beforePhotos.first?.url,
               let url = URL(string: urlString) {
                LazyImage(url: url) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: Constants.maxImageWidth)
                            .frame(maxHeight: Constants.imageSize)
                            .clipped()
                            .cornerRadius(Constants.smallCornerRadius)
                    } else if state.error != nil {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: Constants.imageSize, height: Constants.imageSize)
                            .foregroundColor(.secondary)
                    } else {
                        // Loading state
                        ZStack {
                            RoundedRectangle(cornerRadius: Constants.smallCornerRadius)
                                .fill(Color.gray.opacity(0.2))
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                    }
                }
                .processors([.resize(size: CGSize(width: Constants.imageSize * 2, height: Constants.imageSize * 2))])
                .priority(.high)
//                .failureImage(Image(systemName: "photo"))
//                .transition(.opacity)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: Constants.smallCornerRadius)
                        .fill(Color.gray.opacity(0.1))
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.iconSize, height: Constants.iconSize)
                        .foregroundColor(.secondary)
                }
                .frame(width: Constants.imageSize, height: Constants.imageSize)
            }

            VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                Text(incident.description.prefix(50))
                    .font(.headline)
                    .lineLimit(2)
                HStack {
                    Spacer()
                    Text(incident.startTime.dateValue(), style: .date)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
        }
        .padding(.trailing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(Constants.largeCornerRadius)
    }
}

// MARK: - Constants

/// Layout constants for `IncidentListCell`.
private enum Constants {
    static let imageSize: CGFloat = 80
    static let iconSize: CGFloat = 20
    static let maxImageWidth: CGFloat = 90
    static let smallCornerRadius: CGFloat = 4
    static let largeCornerRadius: CGFloat = 8
    static let cellSpacing: CGFloat = 12
    static let verticalSpacing: CGFloat = 8
    static let smallPadding: CGFloat = 4
    static let statusOpacity: CGFloat = 0.3
}

// #Preview {
//    FreshWallPreview {
//        List {
//            IncidentListCell(
//                incident: Incident(
//                    id: "test",
//                    description: "Sample graffiti incident",
//                    area: 100.0,
//                    createdAt: Date(),
//                    startTime: Date(),
//                    endTime: Date(),
//                    beforePhotos: [
//                        IncidentPhoto(
//                            id: "photo1",
//                            url: "https://picsum.photos/200/200",
//                            uploadedAt: Date(),
//                            fileName: "test.jpg",
//                            metadata: nil
//                        )
//                    ],
//                    afterPhotos: [],
//                    status: .inProgress,
//                    clientId: nil,
//                    client: nil
//                )
//            )
//        }
//    }
// }

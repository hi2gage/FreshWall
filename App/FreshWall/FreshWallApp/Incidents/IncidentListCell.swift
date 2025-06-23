import FirebaseFirestore
import SwiftUI

// MARK: - IncidentListCell

/// A cell view displaying summary information for an incident.
struct IncidentListCell: View {
    let incident: Incident

    var body: some View {
        HStack(alignment: .top, spacing: Constants.cellSpacing) {
            if let urlString = incident.beforePhotos.first?.url,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: Constants.imageSize, height: Constants.imageSize)
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: Constants.maxImageWidth)
                            .clipped()
                            .cornerRadius(Constants.smallCornerRadius)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: Constants.imageSize, height: Constants.imageSize)
                    @unknown default:
                        EmptyView()
                            .frame(width: Constants.imageSize, height: Constants.imageSize)
                    }
                }
            } else {
                ZStack {
                    Color.clear
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.iconSize, height: Constants.iconSize)
                }
                .frame(width: Constants.imageSize, height: Constants.imageSize)
            }

            VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                Text(incident.projectTitle)
                    .font(.headline)
                HStack(spacing: Constants.cellSpacing) {
                    Text(incident.status.capitalized)
                        .font(.subheadline)
                        .padding(Constants.smallPadding)
                        .background(statusColor.opacity(Constants.statusOpacity))
                        .cornerRadius(Constants.smallCornerRadius)
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

    private var statusColor: Color {
        switch incident.status.lowercased() {
        case "completed": .green
        case "in_progress": .orange
        case "open": .blue
        default: .gray
        }
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

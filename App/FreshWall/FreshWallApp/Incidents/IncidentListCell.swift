import FirebaseFirestore
import SwiftUI

/// A cell view displaying summary information for an incident.
struct IncidentListCell: View {
    let incident: Incident

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let urlString = incident.beforePhotos.first?.url,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 80, height: 80)
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(4)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    @unknown default:
                        EmptyView()
                            .frame(width: 80, height: 80)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(incident.projectTitle)
                    .font(.headline)
                HStack(spacing: 12) {
                    Text(incident.status.capitalized)
                        .font(.subheadline)
                        .padding(4)
                        .background(statusColor.opacity(0.3))
                        .cornerRadius(4)
                    Spacer()
                    Text(incident.startTime.dateValue(), style: .date)
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical)
        .padding(.trailing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
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

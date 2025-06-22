import FirebaseFirestore
import SwiftUI

/// A cell view displaying summary information for an incident.
struct IncidentListCell: View {
    let incident: Incident

    var body: some View {
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
        .listCellStyle()
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

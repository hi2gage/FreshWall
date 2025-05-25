import SwiftUI

/// A view displaying detailed information for a specific incident.
struct IncidentDetailView: View {
    let incidentId: String

    var body: some View {
        Text("Details for incident \(incidentId)")
            .navigationTitle("Incident Details")
    }
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            IncidentDetailView(incidentId: "incident123")
        }
    }
}

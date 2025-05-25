import SwiftUI

/// A view displaying detailed information for a specific incident.
struct IncidentDetailView: View {
    let incidentId: String
    let userService: UserService

    var body: some View {
        Text("Details for incident \(incidentId)")
            .navigationTitle("Incident Details")
    }
}

struct IncidentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FreshWallPreview {
            NavigationStack {
                IncidentDetailView(incidentId: "incident123", userService: UserService())
            }
        }
    }
}

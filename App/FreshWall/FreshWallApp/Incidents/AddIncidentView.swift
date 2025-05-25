import SwiftUI

/// View for adding a new incident, injecting a service conforming to `IncidentServiceProtocol`.
struct AddIncidentView: View {
    @Environment(\.dismiss) private var dismiss
    let service: IncidentServiceProtocol

    var body: some View {
        Text("Add Incident View")
            .navigationTitle("Add Incident")
    }
}

struct AddIncidentView_Previews: PreviewProvider {
    static var previews: some View {
        FreshWallPreview {
            NavigationStack {
                AddIncidentView(service: PreviewIncidentService())
            }
        }
    }
}

/// Dummy implementation of `IncidentServiceProtocol` for previews.
private class PreviewIncidentService: IncidentServiceProtocol {
    var incidents: [Incident] = []
    func fetchIncidents() async {}
    func addIncident(_: Incident) async throws {}
}

import SwiftUI

/// A view displaying a list of incidents for the current team.
struct IncidentsListView: View {
    @Environment(RouterPath.self) private var routerPath
    var body: some View {
        List {
            // TODO: Fetch and list incidents from Firestore
            Button("Sample Incident") {
                routerPath.push(.incidentDetail(id: "sampleIncidentID"))
            }
        }
        .navigationTitle("Incidents")
    }
}

struct IncidentsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            IncidentsListView()
        }
    }
}
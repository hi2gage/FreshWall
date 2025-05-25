@preconcurrency import FirebaseFirestore
import SwiftUI

/// A view displaying a list of incidents for the current team.
struct IncidentsListView: View {
    let service: IncidentServiceProtocol
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: IncidentsListViewModel

    /// Initializes the view with an incident service implementing `IncidentServiceProtocol`.
    init(service: IncidentServiceProtocol) {
        self.service = service
        _viewModel = State(wrappedValue: IncidentsListViewModel(service: service))
    }

    var body: some View {
        List {
            if viewModel.incidents.isEmpty {
                Text("No incidents available.")
            } else {
                ForEach(viewModel.incidents) { incident in
                    Button(incident.description) {
                        if let id = incident.id {
                            routerPath.push(.incidentDetail(id: id))
                        }
                    }
                }
            }
        }
        .navigationTitle("Incidents")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    routerPath.push(.addIncident)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            await viewModel.loadIncidents()
        }
    }
}

#Preview {
    let userService = UserService()
    let firestore = Firestore.firestore()
    let service = IncidentService(firestore: firestore, session: .init(userId: "", teamId: ""))
    FreshWallPreview {
        NavigationStack {
            IncidentsListView(service: service)
        }
    }
}

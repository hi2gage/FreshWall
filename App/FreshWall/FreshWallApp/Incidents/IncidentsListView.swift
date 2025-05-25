import FirebaseFirestore
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

struct IncidentsListView_Previews: PreviewProvider {
    static var previews: some View {
        let userService = UserService()
        let firestore = Firestore.firestore()
        let service = IncidentService(firestore: firestore, userService: userService)
        NavigationStack {
            IncidentsListView(service: service)
        }
    }
}

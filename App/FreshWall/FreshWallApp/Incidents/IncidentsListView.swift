import SwiftUI

/// A view displaying a list of incidents for the current team.
struct IncidentsListView: View {
    let userService: UserService
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: IncidentsListViewModel

    init(userService: UserService) {
        self.userService = userService
        _viewModel = State(wrappedValue: IncidentsListViewModel(service: IncidentService(userService: userService)))
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
        .task {
            await viewModel.loadIncidents()
        }
    }
}

struct IncidentsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            IncidentsListView(userService: UserService())
        }
    }
}
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
        GenericListView(
            items: viewModel.incidents,
            title: "Incidents",
            destination: { incident in .incidentDetail(incident: incident) },
            content: { incident in
                IncidentListCell(incident: incident)
            },
            plusButtonAction: {
                routerPath.push(.addIncident)
            }
        )
        .task {
            await viewModel.loadIncidents()
        }
    }
}

#Preview {
    let userService = UserService()
    let firestore = Firestore.firestore()
    let service = IncidentService(
        firestore: firestore,
        session: .init(
            userId: "",
            displayName: "",
            teamId: ""
        )
    )
    FreshWallPreview {
        NavigationStack {
            IncidentsListView(service: service)
        }
    }
}

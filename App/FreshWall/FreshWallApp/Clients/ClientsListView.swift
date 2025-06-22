@preconcurrency import FirebaseFirestore
import SwiftUI

/// A view displaying a list of clients for the current team.
/// A view displaying a list of clients for the current team, ordered by most recent incident.
struct ClientsListView: View {
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: ClientsListViewModel

    /// Initializes the view with services for clients and incidents.
    init(clientService: ClientServiceProtocol, incidentService: IncidentServiceProtocol) {
        _viewModel = State(
            wrappedValue: ClientsListViewModel(
                clientService: clientService,
                incidentService: incidentService
            )
        )
    }

    var body: some View {
        GenericListView(
            items: viewModel.sortedClients(),
            title: "Clients",
            routerDestination: { client in .clientDetail(client: client) },
            content: { client in ClientListCell(client: client) },
            plusButtonAction: {
                routerPath.push(.addClient)
            },
            refreshAction: {
                await viewModel.loadClients()
                await viewModel.loadIncidents()
            },
            menu: {
                Menu {
                    sortingMenu
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        )
        .task {
            await viewModel.loadClients()
            await viewModel.loadIncidents()
        }
    }

    private var sortingMenu: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order By")
                .font(.caption)
                .foregroundColor(.secondary)

            SortButton(for: .alphabetical, sort: $viewModel.sort)
            SortButton(for: .incidentDate, sort: $viewModel.sort)
        }
    }
}

#Preview {
    let firestore = Firestore.firestore()
    let session = UserSession(userId: "", displayName: "", teamId: "team123")

    let incidentModelService = IncidentModelService(firestore: firestore)
    let incidentPhotoService = IncidentPhotoService()
    let clientModelService = ClientModelService(firestore: firestore)
    let userModelService = UserModelService(firestore: firestore)

    let clientService = ClientService(modelService: clientModelService, session: session)
    let incidentService = IncidentService(
        modelService: incidentModelService,
        photoService: incidentPhotoService,
        clientModelService: clientModelService,
        userModelService: userModelService,
        session: session
    )
    FreshWallPreview {
        NavigationStack {
            ClientsListView(
                clientService: clientService,
                incidentService: incidentService
            )
        }
    }
}

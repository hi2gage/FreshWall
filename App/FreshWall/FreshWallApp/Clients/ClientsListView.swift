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
        // Sort clients by most recent incident date
        let sortedClients = viewModel.clients.sorted { lhs, rhs in
            let dateA = lastIncidentDate(for: lhs)
            let dateB = lastIncidentDate(for: rhs)
            return dateA > dateB
        }
        GenericListView(
            items: sortedClients,
            title: "Clients",
            destination: { client in .clientDetail(client: client) },
            content: { client in ClientListCell(client: client) },
            plusButtonAction: {
                routerPath.push(.addClient)
            }
        )
        .task {
            await viewModel.loadClients()
            await viewModel.loadIncidents()
        }
    }

    /// Returns the latest incident date for a given client, or distantPast if none.
    private func lastIncidentDate(for client: ClientDTO) -> Date {
        guard let id = client.id else { return Date.distantPast }
        let dates = viewModel.incidents
            .filter { $0.clientRef.documentID == id }
            .map { $0.createdAt.dateValue() }
        return dates.max() ?? Date.distantPast
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

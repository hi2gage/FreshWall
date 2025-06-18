import FirebaseFirestore
import SwiftUI

/// A view displaying a list of clients for the current team.
struct ClientsListView: View {
    let clientService: ClientServiceProtocol
    let incidentService: IncidentServiceProtocol
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: ClientsListViewModel

    /// Initializes the view with services for clients and incidents.
    init(clientService: ClientServiceProtocol, incidentService: IncidentServiceProtocol) {
        self.clientService = clientService
        self.incidentService = incidentService
        _viewModel = State(wrappedValue: ClientsListViewModel(service: clientService))
    }

    var body: some View {
        GenericListView(
            items: viewModel.clients,
            title: "Clients",
            destination: { client in .clientDetail(client: client) },
            content: { client in ClientListCell(client: client) },
            plusButtonAction: {
                routerPath.push(.addClient)
            }
        )
        .task {
            await viewModel.loadClients()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Picker("Sort", selection: $viewModel.sortOption) {
                    ForEach(ClientSortOption.allCases, id: \ .self) { option in
                        Label(option.title, systemImage: option.symbolName)
                            .tag(option)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: viewModel.sortOption) { _, _ in
                    Task { await viewModel.loadClients() }
                }
            }
        }
    }
}

#Preview {
    let firestore = Firestore.firestore()
    let session = UserSession(userId: "", displayName: "", teamId: "team123")
    let clientService = ClientService(firestore: firestore, session: session)
    let incidentService = IncidentService(firestore: firestore, session: session)
    FreshWallPreview {
        NavigationStack {
            ClientsListView(
                clientService: clientService,
                incidentService: incidentService
            )
        }
    }
}

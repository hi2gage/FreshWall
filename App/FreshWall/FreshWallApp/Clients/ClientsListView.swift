@preconcurrency import FirebaseFirestore
import SwiftUI

/// A view displaying a list of clients for the current team.
struct ClientsListView: View {
    let service: ClientServiceProtocol
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: ClientsListViewModel

    /// Initializes the view with a client service implementing `ClientServiceProtocol`.
    init(service: ClientServiceProtocol) {
        self.service = service
        _viewModel = State(wrappedValue: ClientsListViewModel(service: service))
    }

    var body: some View {
        GenericListView(
            items: viewModel.clients,
            title: "Clients",
            destination: { clients in .clientDetail(client: clients) },
            content: { client in
                ClientListCell(client: client)
            },
            plusButtonAction: {
                routerPath.push(.addClient)
            })
        .task {
            await viewModel.loadClients()
        }
    }
}

#Preview {
    let userService = UserService()
    let firestore = Firestore.firestore()
    let service = ClientService(
        firestore: firestore,
        session: .init(
            userId: "",
            displayName: "",
            teamId: ""
        )
    )
    FreshWallPreview {
        NavigationStack {
            ClientsListView(service: service)
        }
    }
}

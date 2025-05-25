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
        List {
            if viewModel.clients.isEmpty {
                Text("No clients available.")
            } else {
                ForEach(viewModel.clients) { client in
                    Button(client.name) {
                        routerPath.push(.clientDetail(client: client))
                    }
                }
            }
        }
        .navigationTitle("Clients")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    routerPath.push(.addClient)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
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

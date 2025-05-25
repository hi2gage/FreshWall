import SwiftUI

/// A view displaying a list of clients for the current team.
struct ClientsListView: View {
    let userService: UserService
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: ClientsListViewModel

    init(userService: UserService) {
        self.userService = userService
        _viewModel = State(wrappedValue: ClientsListViewModel(service: ClientService(userService: userService)))
    }

    var body: some View {
        List {
            if viewModel.clients.isEmpty {
                Text("No clients available.")
            } else {
                ForEach(viewModel.clients) { client in
                    Button(client.name) {
                        if let id = client.id {
                            routerPath.push(.clientDetail(id: id))
                        }
                    }
                }
            }
        }
        .navigationTitle("Clients")
        .task {
            await viewModel.loadClients()
        }
    }
}

struct ClientsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ClientsListView(userService: UserService())
        }
    }
}

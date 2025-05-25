import SwiftUI

/// View for adding a new client, injecting a service conforming to `ClientServiceProtocol`.
struct AddClientView: View {
    @Environment(\.dismiss) private var dismiss
    let service: ClientServiceProtocol

    var body: some View {
        Text("Add Client View")
            .navigationTitle("Add Client")
    }
}

struct AddClientView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddClientView(service: PreviewClientService())
        }
    }
}

/// Dummy implementation of `ClientServiceProtocol` for previews.
private class PreviewClientService: ClientServiceProtocol {
    var clients: [Client] = []
    func fetchClients() async {}
    func addClient(name _: String, notes _: String?) async throws {}
}

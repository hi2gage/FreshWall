import SwiftUI

/// A view displaying a list of clients for the current team.
struct ClientsListView: View {
    @Environment(RouterPath.self) private var routerPath
    var body: some View {
        List {
            // TODO: Fetch and list clients from Firestore
            Button("Sample Client") {
                routerPath.push(.clientDetail(id: "sampleClientID"))
            }
        }
        .navigationTitle("Clients")
    }
}

struct ClientsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ClientsListView()
        }
    }
}
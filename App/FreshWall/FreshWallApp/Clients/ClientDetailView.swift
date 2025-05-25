import SwiftUI

/// A view displaying detailed information for a specific client.
struct ClientDetailView: View {
    let clientId: String
    let userService: UserService

    var body: some View {
        Text("Details for client \(clientId)")
            .navigationTitle("Client Details")
    }
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            ClientDetailView(clientId: "client123", userService: UserService())
        }
    }
}

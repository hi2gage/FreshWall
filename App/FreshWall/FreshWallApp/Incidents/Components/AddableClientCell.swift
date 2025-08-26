import SwiftUI

struct AddableClientCell: View {
    @Binding var selectedClientId: String?
    let validClients: [Client]
    let onAddNewClient: () -> Void
    let onClientSelected: () async -> Void
    let onNavigateToClient: (Client) -> Void

    private let addNewTag = "ADD_NEW_CLIENT"

    var selectedClient: Client? {
        guard let selectedClientId else { return nil }

        return validClients.first { $0.id == selectedClientId }
    }

    var body: some View {
        if let client = selectedClient {
            // Show selected client with edit button
            HStack {
                Button(client.name) {
                    onNavigateToClient(client)
                }
                .foregroundStyle(.primary)
            }
        } else {
            // Show picker when no client selected
            Picker("Select Client", selection: $selectedClientId) {
                Text("Select Client").tag(nil as String?)
                Text("Add New Client...").tag(addNewTag)
                ForEach(validClients, id: \.id) { client in
                    Text(client.name).tag(client.id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedClientId) { _, newValue in
                if newValue == addNewTag {
                    onAddNewClient()
                    selectedClientId = nil
                } else if newValue != nil {
                    Task {
                        await onClientSelected()
                    }
                }
            }
        }
    }
}

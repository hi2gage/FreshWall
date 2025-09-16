import SwiftUI

struct AddableClientCell: View {
    @Binding var selectedClientId: String?
    let validClients: [Client]
    let onNavigateToClient: (Client) -> Void

    private let addNewTag = "ADD_NEW_CLIENT"

    var selectedClient: Client? {
        guard let selectedClientId else { return nil }

        // Optimized: selected client is guaranteed to be first in the array
        // Fall back to linear search if not found (defensive programming)
        return validClients.first?.id == selectedClientId
            ? validClients.first
            : validClients.first { $0.id == selectedClientId }
    }

    var body: some View {
        if let client = selectedClient {
            // Show selected client with navigate button
            Button(action: {
                onNavigateToClient(client)
            }) {
                HStack {
                    Text(client.name)
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } else {
            // Show picker when no client selected
            Picker("Select Client", selection: $selectedClientId) {
                Text("Select Client")
                    .tag(nil as String?)
                Text("Add New Client...")
                    .tag(addNewTag)
                ForEach(validClients, id: \.id) { client in
                    Text(client.name)
                        .tag(client.id)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

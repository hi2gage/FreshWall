import SwiftUI

// MARK: - ClientSelectionSection

/// Client selection section for incident forms
struct ClientSelectionSection: View {
    @Binding var clientId: String?
    let validClients: [(id: String, name: String)]
    let addNewTag: String
    let onClientChange: (String?) -> Void

    var body: some View {
        Section("Client") {
            Picker("Select Client", selection: $clientId) {
                Text("Select").tag(nil as String?)
                Text("Add New Client...").tag(addNewTag)
                ForEach(validClients, id: \.id) { item in
                    Text(item.name).tag(item.id as String?)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: clientId) { _, newValue in
                onClientChange(newValue)
            }
        }
    }
}

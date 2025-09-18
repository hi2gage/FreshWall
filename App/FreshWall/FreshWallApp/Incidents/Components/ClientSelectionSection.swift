import SwiftUI

// MARK: - ClientSelectionSection

/// Client selection section for incident forms
struct ClientSelectionSection: View {
    @Binding var clientId: String?
    let validClients: [(id: String, name: String)]
    let addNewTag: String
    let onClientChange: (String?) -> Void

    /// Convenience initializer using the shared constant
    init(
        clientId: Binding<String?>,
        validClients: [(id: String, name: String)],
        onClientChange: @escaping (String?) -> Void
    ) {
        self._clientId = clientId
        self.validClients = validClients
        self.addNewTag = IncidentFormConstants.addNewClientTag
        self.onClientChange = onClientChange
    }

    /// Full initializer for custom add new tag
    init(
        clientId: Binding<String?>,
        validClients: [(id: String, name: String)],
        addNewTag: String,
        onClientChange: @escaping (String?) -> Void
    ) {
        self._clientId = clientId
        self.validClients = validClients
        self.addNewTag = addNewTag
        self.onClientChange = onClientChange
    }

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

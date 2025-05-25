import SwiftUI

/// View for adding a new client, injecting a service conforming to `ClientServiceProtocol`.
@preconcurrency import FirebaseFirestore
import SwiftUI

struct AddClientView: View {
    @Environment(\.dismiss) private var dismiss
    let service: ClientServiceProtocol
    @State private var name: String = ""
    @State private var notes: String = ""

    var body: some View {
        Form {
            Section("Name") {
                TextField("Client Name", text: $name)
            }
            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle("Add Client")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        try? await service.addClient(name: name, notes: notes.isEmpty ? nil : notes)
                        dismiss()
                    }
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

/// Dummy implementation of `ClientServiceProtocol` for previews.
@MainActor
private class PreviewClientService: ClientServiceProtocol {
    var clients: [Client] = []
    func fetchClients() async throws -> [Client] { [] }
    func addClient(name _: String, notes _: String?) async throws {}
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            AddClientView(service: PreviewClientService())
        }
    }
}

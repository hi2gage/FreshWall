import SwiftUI

/// View for adding a new client, injecting a service conforming to `ClientServiceProtocol`.

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
                        do {
                            let input = AddClientInput(
                                name: name.trimmingCharacters(in: .whitespaces),
                                notes: notes.isEmpty ? nil : notes
                            )
                            try await service.addClient(input)
                            dismiss()
                        } catch {
                            // Handle error if needed
                        }
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
    func fetchClients() async throws -> [Client] { [] }
    func addClient(_: AddClientInput) async throws {}
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            AddClientView(service: PreviewClientService())
        }
    }
}

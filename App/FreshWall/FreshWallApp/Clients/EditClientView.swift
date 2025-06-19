import SwiftUI

/// View for editing an existing client, injecting a service conforming to `ClientServiceProtocol`.
struct EditClientView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditClientViewModel

    init(viewModel: EditClientViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("Client Name", text: $viewModel.name)
            }
            Section("Notes") {
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle("Edit Client")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        do {
                            try await viewModel.save()
                            dismiss()
                        } catch {
                            // Handle error if needed
                        }
                    }
                }
                .disabled(!viewModel.isValid)
            }
        }
    }
}

@MainActor
private class PreviewClientService: ClientServiceProtocol {
    func fetchClients(sortedBy _: ClientSortOption) async throws -> [ClientDTO] {
        [ClientDTO(
            id: "client1",
            name: "Sample Client",
            notes: "Preview client",
            isDeleted: false,
            deletedAt: nil,
            createdAt: .init(),
            lastIncidentAt: .init()
        )]
    }

    func addClient(_: AddClientInput) async throws {}

    func updateClient(_: String, with _: UpdateClientInput) async throws {}
}

#Preview {
    let sampleClient = ClientDTO(
        id: "client123",
        name: "Test Client",
        notes: "Sample notes",
        isDeleted: false,
        deletedAt: nil,
        createdAt: .init(),
        lastIncidentAt: .init()
    )
    let service = PreviewClientService()
    FreshWallPreview {
        NavigationStack {
            EditClientView(viewModel: EditClientViewModel(client: sampleClient, service: service))
        }
    }
}

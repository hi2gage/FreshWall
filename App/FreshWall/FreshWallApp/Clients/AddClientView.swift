import SwiftUI

/// View for adding a new client, injecting a service conforming to `ClientServiceProtocol`.
struct AddClientView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddClientViewModel

    /// Initializes view with injected client service and view model.
    init(viewModel: AddClientViewModel) {
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
        .navigationTitle("Add Client")
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

/// Dummy implementation of `ClientServiceProtocol` for previews.
@MainActor
private class PreviewClientService: ClientServiceProtocol {
    func fetchClients(sortedBy _: ClientSortOption) async throws -> [ClientDTO] { [] }
    func addClient(_: AddClientInput) async throws {}
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            AddClientView(viewModel: AddClientViewModel(service: PreviewClientService()))
        }
    }
}

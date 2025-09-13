import SwiftUI

// MARK: - AddClientView

/// View for adding a new client, injecting a service conforming to `ClientServiceProtocol`.
struct AddClientView: View {
    typealias BillingMethod = ClientDTO.BillingMethod

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddClientViewModel
    private let onClientCreated: ((String) -> Void)?

    /// Initializes view with injected client service and view model.
    init(viewModel: AddClientViewModel, onClientCreated: ((String) -> Void)? = nil) {
        _viewModel = State(wrappedValue: viewModel)
        self.onClientCreated = onClientCreated
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

            Section("Billing Defaults") {
                Toggle("Configure billing defaults", isOn: $viewModel.includeDefaults)

                if viewModel.includeDefaults {
                    VStack(alignment: .leading, spacing: 16) {
                        // Billing Method Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Billing Method")
                                .font(.headline)
                            Picker("Billing Method", selection: $viewModel.billingMethod) {
                                ForEach(BillingMethod.allCases, id: \.self) { method in
                                    Text(method.displayName).tag(method)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        // Minimum Billable Quantity
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Minimum Billable Quantity")
                                .font(.headline)
                            HStack {
                                TextField("0", text: $viewModel.minimumBillableQuantity)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                Text(viewModel.billingMethod.unitLabel)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Amount Per Unit
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount Per Unit")
                                .font(.headline)
                            HStack {
                                Text("$")
                                    .foregroundColor(.secondary)
                                TextField("0.00", text: $viewModel.amountPerUnit)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                Text("per \(viewModel.billingMethod.unitLabel)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Add Client")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        do {
                            let clientId = try await viewModel.save()
                            onClientCreated?(clientId)
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

// MARK: - PreviewClientService

/// Dummy implementation of `ClientServiceProtocol` for previews.
@MainActor
private class PreviewClientService: ClientServiceProtocol {
    func deleteClient(_: String) async throws {}
    func fetchClients() async throws -> [Client] { [] }
    func addClient(_: AddClientInput) async throws -> String { "preview-id" }
    func updateClient(_: String, with _: UpdateClientInput) async throws {}
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            AddClientView(viewModel: AddClientViewModel(service: PreviewClientService()))
        }
    }
}

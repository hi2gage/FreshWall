import SwiftUI

// MARK: - EditClientView

/// View for editing an existing client, injecting a service conforming to `ClientServiceProtocol`.
struct EditClientView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RouterPath.self) private var routerPath
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

            Section {
                Button("Delete Client") {
                    viewModel.showingDeleteAlert = true
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Edit Client")
        .toolbar {
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
        .alert("Delete Client", isPresented: $viewModel.showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await viewModel.delete()
                        // Pop twice: Edit → Detail → List
                        routerPath.pop(count: 2)
                    } catch {
                        // Handle error if needed
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this client? This action cannot be undone.")
        }
    }
}

// MARK: - PreviewClientService

@MainActor
private class PreviewClientService: ClientServiceProtocol {
    func fetchClients() async throws -> [Client] {
        [Client(
            id: "client1",
            name: "Sample Client",
            notes: "Preview client",
            isDeleted: false,
            deletedAt: nil,
            createdAt: .init(),
            lastIncidentAt: .init()
        )]
    }

    func addClient(_: AddClientInput) async throws -> String { "preview-id" }

    func updateClient(_: String, with _: UpdateClientInput) async throws {}

    func deleteClient(_: String) async throws {}
}

#Preview {
    let sampleClient = Client(
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

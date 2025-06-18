@preconcurrency import FirebaseFirestore
import SwiftUI

/// View for editing an existing incident.
struct EditIncidentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditIncidentViewModel
    private let addNewTag = "__ADD_NEW__"

    init(viewModel: EditIncidentViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Section("Client") {
                Picker("Select Client", selection: $viewModel.clientId) {
                    Text("Add New Client...").tag(addNewTag)
                    ForEach(viewModel.validClients, id: \.id) { item in
                        Text(item.name).tag(item.id)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: viewModel.clientId) { _, newValue in
                    if newValue == addNewTag {
                        // For previews this does nothing. Real usage pushes via router.
                        viewModel.clientId = ""
                    }
                }
            }
            Section("Description") {
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 100)
            }
            Section("Area (sq ft)") {
                TextField("Area", text: $viewModel.areaText)
                    .keyboardType(.decimalPad)
            }
            Section("Timeframe") {
                DatePicker(
                    "Start Time",
                    selection: $viewModel.startTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                DatePicker(
                    "End Time",
                    selection: $viewModel.endTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            Section {
                Toggle("Billable", isOn: $viewModel.billable)
                if viewModel.billable {
                    TextField("Rate", text: $viewModel.rateText)
                        .keyboardType(.decimalPad)
                }
            }
            Section("Project Name") {
                TextField("Project Name", text: $viewModel.projectName)
            }
            Section("Status") {
                Picker("Status", selection: $viewModel.status) {
                    ForEach(viewModel.statusOptions, id: \.self) { option in
                        Text(option.capitalized).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section("Materials Used") {
                TextEditor(text: $viewModel.materialsUsed)
                    .frame(minHeight: 80)
            }
        }
        .navigationTitle("Edit Incident")
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
                        } catch {}
                    }
                }
                .disabled(!viewModel.isValid)
            }
        }
        .task {
            await viewModel.loadClients()
        }
    }
}

@MainActor
private class PreviewIncidentService: IncidentServiceProtocol {
    func fetchIncidents() async throws -> [IncidentDTO] { [] }
    func addIncident(_: IncidentDTO) async throws {}
    func addIncident(_: AddIncidentInput) async throws {}
    func updateIncident(_: String, with _: UpdateIncidentInput) async throws {}
}

@MainActor
private class PreviewClientService: ClientServiceProtocol {
    func fetchClients(sortedBy _: ClientSortOption) async throws -> [ClientDTO] {
        [ClientDTO(
            id: "client1",
            name: "Sample Client",
            notes: nil,
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
    let incident = IncidentDTO(
        id: "inc1",
        clientRef: Firestore.firestore().document("teams/t/clients/client1"),
        workerRefs: [],
        description: "Some incident",
        area: 10,
        createdAt: .init(),
        startTime: .init(),
        endTime: .init(),
        beforePhotoUrls: [],
        afterPhotoUrls: [],
        createdBy: Firestore.firestore().document("teams/t/users/u"),
        lastModifiedBy: nil,
        lastModifiedAt: nil,
        billable: false,
        rate: nil,
        projectName: nil,
        status: "open",
        materialsUsed: nil
    )
    let service = PreviewIncidentService()
    let clientService = PreviewClientService()
    FreshWallPreview {
        NavigationStack {
            EditIncidentView(
                viewModel: EditIncidentViewModel(
                    incident: incident,
                    incidentService: service,
                    clientService: clientService
                )
            )
        }
    }
}

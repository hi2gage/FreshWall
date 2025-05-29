import SwiftUI

/// View for adding a new incident, injecting a service conforming to `IncidentServiceProtocol`.

struct AddIncidentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RouterPath.self) private var routerPath
    @State var viewModel: AddIncidentViewModel
    private let addNewTag = "__ADD_NEW__"

    /// Initializes the view with a view model.
    init(viewModel: AddIncidentViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Section(header: Text("Client")) {
                Picker("Select Client", selection: $viewModel.clientId) {
                    Text("Add New Client...").tag(addNewTag)
                    ForEach(viewModel.validClients, id: \.id) { item in
                        Text(item.name).tag(item.id)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: viewModel.clientId) { _, newValue in
                    if newValue == addNewTag {
                        routerPath.push(.addClient)
                        viewModel.clientId = ""
                    }
                }
            }
            Section(header: Text("Description")) {
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 100)
            }
            Section(header: Text("Area (sq ft)")) {
                TextField("Area", text: $viewModel.areaText)
                    .keyboardType(.decimalPad)
            }
            Section(header: Text("Timeframe")) {
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
            Section(header: Text("Project Name")) {
                TextField("Project Name", text: $viewModel.projectName)
            }
            Section(header: Text("Status")) {
                Picker("Status", selection: $viewModel.status) {
                    ForEach(viewModel.statusOptions, id: \.self) { option in
                        Text(option.capitalized).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section(header: Text("Materials Used")) {
                TextEditor(text: $viewModel.materialsUsed)
                    .frame(minHeight: 80)
            }
        }
        .navigationTitle("Add Incident")
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
                .disabled(viewModel.isValid)
            }
        }
        .task {
            await viewModel.loadClients()
        }
    }
}

/// Dummy implementations of services for previews.
@MainActor
private class PreviewIncidentService: IncidentServiceProtocol {
    func fetchIncidents() async throws -> [Incident] { [] }
    func addIncident(_: Incident) async throws {}
    func addIncident(_: AddIncidentInput) async throws {}
}
@MainActor
private class PreviewClientService: ClientServiceProtocol {
    func fetchClients() async throws -> [Client] {
        [Client(
            id: "client1",
            name: "Sample Client",
            notes: "Preview client",
            isDeleted: false,
            deletedAt: nil,
            createdAt: .init()
        )]
    }
    func addClient(_: AddClientInput) async throws {}
}

#Preview {
    let incidentService = PreviewIncidentService()
    let clientService = PreviewClientService()
    FreshWallPreview {
        NavigationStack {
            AddIncidentView(
                viewModel: AddIncidentViewModel(
                    service: incidentService,
                    clientService: clientService
                )
            )
        }
    }
}

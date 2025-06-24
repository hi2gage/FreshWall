@preconcurrency import FirebaseFirestore
import PhotosUI
import SwiftUI

// MARK: - EditIncidentView

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
            Section("Project Title") {
                TextField("Project Title", text: $viewModel.projectTitle)
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
            if !viewModel.beforePhotos.isEmpty {
                Section("Before Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.beforePhotos.indices, id: \.self) { idx in
                                Image(uiImage: viewModel.beforePhotos[idx].image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                            }
                        }
                    }
                    .frame(height: 120)
                }
            }
            PhotoPicker(selection: $viewModel.beforePhotos, matching: .images, photoLibrary: .shared()) {
                Label("Add Before Photos", systemImage: "photo.on.rectangle")
            }
            if !viewModel.afterPhotos.isEmpty {
                Section("After Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.afterPhotos.indices, id: \.self) { idx in
                                Image(uiImage: viewModel.afterPhotos[idx].image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                            }
                        }
                    }
                    .frame(height: 120)
                }
            }
            PhotoPicker(selection: $viewModel.afterPhotos, matching: .images, photoLibrary: .shared()) {
                Label("Add After Photos", systemImage: "photo.fill.on.rectangle.fill")
            }
        }
        .navigationTitle("Edit Incident")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        do {
                            try await viewModel.save(
                                beforePhotos: viewModel.beforePhotos,
                                afterPhotos: viewModel.afterPhotos
                            )
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

// MARK: - PreviewClientService

@MainActor
private class PreviewClientService: ClientServiceProtocol {
    func fetchClients(sortedBy _: ClientSortOption) async throws -> [Client] {
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

    func addClient(_: AddClientInput) async throws {}

    func updateClient(_: String, with _: UpdateClientInput) async throws {}
}

// MARK: - PreviewIncidentService

/// Dummy implementations of services for previews.
@MainActor
private class PreviewIncidentService: IncidentServiceProtocol {
    func fetchIncidents() async throws -> [Incident] { [] }
    func addIncident(_: Incident) async throws {}
    func addIncident(
        _: AddIncidentInput,
        beforePhotos _: [PickedPhoto],
        afterPhotos _: [PickedPhoto]
    ) async throws {}
    func updateIncident(
        _: String,
        with _: UpdateIncidentInput,
        beforePhotos _: [PickedPhoto],
        afterPhotos _: [PickedPhoto]
    ) async throws {}
}

#Preview {
    let incident = Incident(
        id: "inc1",
        projectTitle: "",
        clientRef: Firestore.firestore().document("teams/t/clients/client1"),
        workerRefs: [],
        description: "Some incident",
        area: 10,
        createdAt: .init(),
        startTime: .init(),
        endTime: .init(),
        beforePhotos: [],
        afterPhotos: [],
        createdBy: Firestore.firestore().document("teams/t/users/u"),
        lastModifiedBy: nil,
        lastModifiedAt: nil,
        billable: false,
        rate: nil,
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

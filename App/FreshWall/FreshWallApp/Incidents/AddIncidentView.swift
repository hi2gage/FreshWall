import PhotosUI
import SwiftUI

// MARK: - AddIncidentView

/// View for adding a new incident, injecting a service conforming to `IncidentServiceProtocol`.

struct AddIncidentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RouterPath.self) private var routerPath
    @State var viewModel: AddIncidentViewModel
    private let addNewTag = "__ADD_NEW__"
    @State private var beforePhotos: [PickedPhoto] = []
    @State private var afterPhotos: [PickedPhoto] = []

    /// Initializes the view with a view model.
    init(viewModel: AddIncidentViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Section(header: Text("Area (sq ft)")) {
                TextField("Area", text: $viewModel.input.areaText)
                    .keyboardType(.decimalPad)
            }
            if !beforePhotos.isEmpty {
                Section("Before Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(beforePhotos.indices, id: \.self) { idx in
                                Image(uiImage: beforePhotos[idx].image)
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
            PhotoSourcePicker(selection: $beforePhotos, matching: .images, photoLibrary: .shared()) {
                Label("Add Before Photos", systemImage: "photo.on.rectangle")
            }
            if !afterPhotos.isEmpty {
                Section("After Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(afterPhotos.indices, id: \.self) { idx in
                                Image(uiImage: afterPhotos[idx].image)
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
            PhotoSourcePicker(selection: $afterPhotos, matching: .images, photoLibrary: .shared()) {
                Label("Add After Photos", systemImage: "photo.fill.on.rectangle.fill")
            }
            Section(header: Text("Timeframe")) {
                DatePicker(
                    "Start Time",
                    selection: $viewModel.input.startTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                DatePicker(
                    "End Time",
                    selection: $viewModel.input.endTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            Section(header: Text("Client")) {
                Picker("Select Client", selection: $viewModel.input.clientId) {
                    Text("Add New Client...").tag(addNewTag)
                    ForEach(viewModel.validClients, id: \.id) { item in
                        Text(item.name).tag(item.id)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: viewModel.input.clientId) { _, newValue in
                    if newValue == addNewTag {
                        routerPath.push(.addClient())
                        viewModel.input.clientId = ""
                    }
                }
            }
            Section(header: Text("Notes")) {
                TextEditor(text: $viewModel.input.description)
                    .frame(minHeight: 100)
            }
            Section("Rate") {
                TextField("Rate", text: $viewModel.input.rateText)
                    .keyboardType(.decimalPad)
            }
            Section("Location") {
                if let location = viewModel.input.location {
                    HStack {
                        Text("📍 \(location.shortDisplayString)")
                        Spacer()
                        Button("Edit") {
                            viewModel.showingLocationMap = true
                        }
                    }
                } else {
                    Button("📍 Add Location") {
                        viewModel.showingLocationMap = true
                    }
                    .foregroundColor(.blue)
                }
            }
            Section(header: Text("Materials Used")) {
                TextEditor(text: $viewModel.input.materialsUsed)
                    .frame(minHeight: 80)
            }
        }
        .navigationTitle("Add Incident")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        do {
                            try await viewModel.save(beforePhotos: beforePhotos, afterPhotos: afterPhotos)
                            dismiss()
                        } catch {
                            // Handle error if needed
                        }
                    }
                }
                .disabled(!viewModel.isValid)
            }
        }
        .sheet(isPresented: $viewModel.showingLocationMap) {
            LocationMapView(location: $viewModel.input.location)
        }
        .task {
            await viewModel.loadClients()
        }
    }
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
    func deleteIncident(_: String) async throws {}
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

    func addClient(_: AddClientInput) async throws -> String { "mock-id" }
    func updateClient(_: String, with _: UpdateClientInput) async throws {}
    func deleteClient(_: String) async throws {}
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

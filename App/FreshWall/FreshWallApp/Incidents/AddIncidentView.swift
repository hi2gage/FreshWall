import PhotosUI
import SwiftUI

/// View for adding a new incident, injecting a service conforming to `IncidentServiceProtocol`.

struct AddIncidentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RouterPath.self) private var routerPath
    @State var viewModel: AddIncidentViewModel
    private let addNewTag = "__ADD_NEW__"
    @State private var beforePickerItems: [PhotosPickerItem] = []
    @State private var afterPickerItems: [PhotosPickerItem] = []
    @State private var beforeImages: [UIImage] = []
    @State private var afterImages: [UIImage] = []

    /// Initializes the view with a view model.
    init(viewModel: AddIncidentViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
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
                        routerPath.push(.addClient)
                        viewModel.input.clientId = ""
                    }
                }
            }
            Section(header: Text("Project Title")) {
                TextField("Project Title", text: $viewModel.input.projectTitle)
            }
            Section(header: Text("Notes")) {
                TextEditor(text: $viewModel.input.description)
                    .frame(minHeight: 100)
            }
            Section(header: Text("Area (sq ft)")) {
                TextField("Area", text: $viewModel.input.areaText)
                    .keyboardType(.decimalPad)
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
            Section {
                Toggle("Billable", isOn: $viewModel.input.billable)
                if viewModel.input.billable {
                    TextField("Rate", text: $viewModel.input.rateText)
                        .keyboardType(.decimalPad)
                }
            }
            Section(header: Text("Status")) {
                Picker("Status", selection: $viewModel.input.status) {
                    ForEach(viewModel.statusOptions, id: \.self) { option in
                        Text(option.capitalized).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section(header: Text("Materials Used")) {
                TextEditor(text: $viewModel.input.materialsUsed)
                    .frame(minHeight: 80)
            }
            if !beforeImages.isEmpty {
                Section("Before Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(beforeImages.indices, id: \.self) { idx in
                                Image(uiImage: beforeImages[idx])
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
            PhotosPicker(selection: $beforePickerItems, matching: .images, photoLibrary: .shared()) {
                Label("Add Before Photos", systemImage: "photo.on.rectangle")
            }
            if !afterImages.isEmpty {
                Section("After Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(afterImages.indices, id: \.self) { idx in
                                Image(uiImage: afterImages[idx])
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
            PhotosPicker(selection: $afterPickerItems, matching: .images, photoLibrary: .shared()) {
                Label("Add After Photos", systemImage: "photo.fill.on.rectangle.fill")
            }
        }
        .navigationTitle("Add Incident")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        do {
                            let beforeData = beforeImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
                            let afterData = afterImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
                            try await viewModel.save(beforeImages: beforeData, afterImages: afterData)
                            dismiss()
                        } catch {
                            // Handle error if needed
                        }
                    }
                }
                .disabled(!viewModel.isValid)
            }
        }
        .task {
            await viewModel.loadClients()
        }
        .onChange(of: beforePickerItems) { _, newItems in
            Task {
                beforeImages = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data)
                    {
                        beforeImages.append(image)
                    }
                }
            }
        }
        .onChange(of: afterPickerItems) { _, newItems in
            Task {
                afterImages = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data)
                    {
                        afterImages.append(image)
                    }
                }
            }
        }
    }
}

/// Dummy implementations of services for previews.
@MainActor
private class PreviewIncidentService: IncidentServiceProtocol {
    func fetchIncidents() async throws -> [Incident] { [] }
    func addIncident(_: Incident) async throws {}
    func addIncident(
        _: AddIncidentInput,
        beforeImages _: [Data],
        afterImages _: [Data]
    ) async throws {}
    func updateIncident(
        _: String,
        with _: UpdateIncidentInput,
        beforeImages _: [Data],
        afterImages _: [Data]
    ) async throws {}
}

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

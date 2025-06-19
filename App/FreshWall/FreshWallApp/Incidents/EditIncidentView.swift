@preconcurrency import FirebaseFirestore
import PhotosUI
import SwiftUI

/// View for editing an existing incident.
struct EditIncidentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditIncidentViewModel
    private let addNewTag = "__ADD_NEW__"
    @State private var beforePickerItems: [PhotosPickerItem] = []
    @State private var afterPickerItems: [PhotosPickerItem] = []
    @State private var beforeImages: [UIImage] = []
    @State private var afterImages: [UIImage] = []
    @State private var viewerIndex = 0
    @State private var viewerSources: [PhotoSource] = []
    @State private var showingViewer = false

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
            if !(viewModel.beforeUrls.isEmpty && beforeImages.isEmpty) {
                Section("Before Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(viewModel.beforeUrls.enumerated()), id: \.1) { idx, url in
                                ZStack(alignment: .topTrailing) {
                                    AsyncImage(url: URL(string: url)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case let .success(image):
                                            image.resizable().scaledToFill()
                                        case .failure:
                                            Image(systemName: "photo")
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .onTapGesture {
                                        viewerSources = viewModel.beforeUrls.map { PhotoSource.url($0) } + beforeImages.map { PhotoSource.uiImage($0) }
                                        viewerIndex = idx
                                        showingViewer = true
                                    }
                                    Button {
                                        viewModel.beforeUrls.remove(at: idx)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white)
                                            .padding(4)
                                    }
                                }
                            }
                            ForEach(beforeImages.indices, id: \.self) { idx in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: beforeImages[idx])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .onTapGesture {
                                            viewerSources = viewModel.beforeUrls.map { PhotoSource.url($0) } + beforeImages.map { PhotoSource.uiImage($0) }
                                            viewerIndex = viewModel.beforeUrls.count + idx
                                            showingViewer = true
                                        }
                                    Button {
                                        beforeImages.remove(at: idx)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white)
                                            .padding(4)
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 120)
                }
            }
            PhotosPicker(selection: $beforePickerItems, matching: .images, photoLibrary: .shared()) {
                Label("Add Before Photos", systemImage: "photo.on.rectangle")
            }
            if !(viewModel.afterUrls.isEmpty && afterImages.isEmpty) {
                Section("After Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(viewModel.afterUrls.enumerated()), id: \.1) { idx, url in
                                ZStack(alignment: .topTrailing) {
                                    AsyncImage(url: URL(string: url)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case let .success(image):
                                            image.resizable().scaledToFill()
                                        case .failure:
                                            Image(systemName: "photo")
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .onTapGesture {
                                        viewerSources = viewModel.afterUrls.map { PhotoSource.url($0) } + afterImages.map { PhotoSource.uiImage($0) }
                                        viewerIndex = idx
                                        showingViewer = true
                                    }
                                    Button {
                                        viewModel.afterUrls.remove(at: idx)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white)
                                            .padding(4)
                                    }
                                }
                            }
                            ForEach(afterImages.indices, id: \.self) { idx in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: afterImages[idx])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .onTapGesture {
                                            viewerSources = viewModel.afterUrls.map { PhotoSource.url($0) } + afterImages.map { PhotoSource.uiImage($0) }
                                            viewerIndex = viewModel.afterUrls.count + idx
                                            showingViewer = true
                                        }
                                    Button {
                                        afterImages.remove(at: idx)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white)
                                            .padding(4)
                                    }
                                }
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
        .navigationTitle("Edit Incident")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        do {
                            let beforeData = beforeImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
                            let afterData = afterImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
                            try await viewModel.save(beforeImages: beforeData, afterImages: afterData)
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
        .onChange(of: beforePickerItems) { _, newItems in
            Task {
                beforeImages = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
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
                       let image = UIImage(data: data) {
                        afterImages.append(image)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingViewer) {
            PhotoViewer(sources: viewerSources, index: $viewerIndex)
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

/// Dummy implementations of services for previews.
@MainActor
private class PreviewIncidentService: IncidentServiceProtocol {
    func fetchIncidents() async throws -> [IncidentDTO] { [] }
    func addIncident(_: IncidentDTO) async throws {}
    func addIncident(
        _ : AddIncidentInput,
        beforeImages _: [Data],
        afterImages _: [Data]
    ) async throws {}
    func updateIncident(
        _ : String,
        with _: UpdateIncidentInput,
        beforeImages _: [Data],
        afterImages _: [Data]
    ) async throws {}
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

@preconcurrency import FirebaseFirestore
import SwiftUI

// MARK: - IncidentDetailView

/// A view displaying detailed information for a specific incident.
struct IncidentDetailView: View {
    @State private var viewModel: IncidentDetailViewModel
    @State private var showingDeleteConfirmation = false
    @Environment(RouterPath.self) private var routerPath

    init(
        incident: Incident,
        incidentService: IncidentServiceProtocol,
        clientService: ClientServiceProtocol
    ) {
        _viewModel = State(wrappedValue: IncidentDetailViewModel(
            incident: incident,
            incidentService: incidentService,
            clientService: clientService
        ))
    }

    private func deleteIncident() async {
        do {
            try await viewModel.deleteIncident()
            routerPath.pop()
        } catch {
            print("Failed to delete incident: \(error)")
        }
    }

    var body: some View {
        List {
            // MARK: - Photos Section (Top Priority)

            DetailPhotosSection(
                beforePhotos: viewModel.incident.beforePhotos,
                afterPhotos: viewModel.incident.afterPhotos,
                pickedBeforePhotos: $viewModel.pickedBeforePhotos,
                pickedAfterPhotos: $viewModel.pickedAfterPhotos
            )

            // MARK: - Timeline Section

            DetailTimelineSection(
                startTime: viewModel.incident.startTime,
                endTime: viewModel.incident.endTime
            )

            // MARK: - Client Section

            DetailClientSection(
                selectedClientId: $viewModel.selectedClientId,
                validClients: viewModel.clients,
                onAddNewClient: {
                    // Clear the selection temporarily
                    viewModel.selectedClientId = nil
                    routerPath.push(.addClient(onClientCreated: { clientId in
                        Task {
                            await viewModel.handleNewClientCreated(clientId)
                        }
                    }))
                },
                onClientSelected: {
                    await viewModel.updateIncident(newClientId: viewModel.selectedClientId)
                },
                onNavigateToClient: { client in
                    routerPath.push(.clientDetail(client: client))
                }
            )

            // MARK: - Billing Section

            if let selectedClient = viewModel.clients.first(where: { $0.id == viewModel.selectedClientId }) {
                BillingDisplayView(
                    billing: BillingDisplayModel(incident: viewModel.incident, client: selectedClient),
                    context: .incident
                )
            }

            // MARK: - Surface Type Section

            if viewModel.incident.surfaceType != nil {
                DetailSurfaceTypeSection(
                    surfaceType: viewModel.incident.surfaceType,
                    surfaceDisplayName: viewModel.incident.surfaceDisplayName,
                    customSurfaceDescription: viewModel.incident.customSurfaceDescription
                )
            }

            // MARK: - Location Section

            DetailLocationSection(
                bestLocation: viewModel.incident.bestLocation,
                onLocationCapture: {
                    routerPath.presentLocationCapture(currentLocation: nil) { newLocation in
                        if let newLocation {
                            Task {
                                await viewModel.updateIncident(newLocation: newLocation)
                            }
                        }
                    }
                }
            )

            // MARK: - Materials Section

            if let materialsUsed = viewModel.incident.materialsUsed, !materialsUsed.isEmpty {
                Section("Materials Used") {
                    Text(materialsUsed)
                        .font(.body)
                }
            }

            // MARK: - Enhanced Notes Section

            DetailNotesSection(
                enhancedNotes: viewModel.incident.enhancedNotes,
                description: viewModel.incident.description,
                onDescriptionUpdate: {
                    await viewModel.updateIncident()
                }
            )
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Incident Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { routerPath.push(.editIncident(incident: viewModel.incident)) }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Delete Incident", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
        }
        .alert("Delete Incident", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await deleteIncident()
                }
            }
        } message: {
            Text("Are you sure you want to delete this incident? This action cannot be undone.")
        }
        .task {
            await viewModel.reloadIncident()
        }
        .refreshable {
            await viewModel.reloadIncident()
        }
        .onChange(of: viewModel.pickedBeforePhotos) { _, newPhotos in
            if !newPhotos.isEmpty {
                Task {
                    await viewModel.updateIncident(beforePhotos: newPhotos)
                    viewModel.pickedBeforePhotos.removeAll()
                }
            }
        }
        .onChange(of: viewModel.pickedAfterPhotos) { _, newPhotos in
            if !newPhotos.isEmpty {
                Task {
                    await viewModel.updateIncident(afterPhotos: newPhotos)
                    viewModel.pickedAfterPhotos.removeAll()
                }
            }
        }
    }
}

// MARK: - DetailPhotosSection

/// Photos section for incident detail view
struct DetailPhotosSection: View {
    let beforePhotos: [IncidentPhoto]?
    let afterPhotos: [IncidentPhoto]?
    @Binding var pickedBeforePhotos: [PickedPhoto]
    @Binding var pickedAfterPhotos: [PickedPhoto]

    var body: some View {
        Section("Photos") {
            if beforePhotos?.isEmpty != false {
                PhotoSourcePicker(
                    selection: $pickedBeforePhotos,
                    maxSelectionCount: 10,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Add Before Photos", systemImage: "camera.fill")
                }
            } else if let beforePhotos = beforePhotos?.nullIfEmpty {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Before Photos")
                        Spacer()
                        PhotoSourcePicker(
                            selection: $pickedBeforePhotos,
                            maxSelectionCount: 10,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.accentColor)
                        }
                    }
                    PhotoCarousel(photos: beforePhotos)
                }
            }

            if afterPhotos?.isEmpty != false {
                PhotoSourcePicker(
                    selection: $pickedAfterPhotos,
                    maxSelectionCount: 10,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Add After Photos", systemImage: "camera.fill")
                }
            } else if let afterPhotos = afterPhotos?.nullIfEmpty {
                VStack(alignment: .leading) {
                    HStack {
                        Text("After Photos")
                        Spacer()
                        PhotoSourcePicker(
                            selection: $pickedAfterPhotos,
                            maxSelectionCount: 10,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.accentColor)
                        }
                    }
                    PhotoCarousel(photos: afterPhotos)
                }
            }
        }
    }
}

// MARK: - DetailTimelineSection

/// Timeline section for incident detail view
struct DetailTimelineSection: View {
    let startTime: Timestamp
    let endTime: Timestamp

    var body: some View {
        Section("Timeline") {
            HStack {
                Text("Start Time")
                Spacer()
                Text(startTime.dateValue(), style: .time)
            }
            HStack {
                Text("End Time")
                Spacer()
                Text(endTime.dateValue(), style: .time)
            }

            // Show duration
            HStack {
                Text("Duration")
                    .font(.headline)
                Spacer()
                let hours = endTime.dateValue().timeIntervalSince(startTime.dateValue()) / 3600
                Text(String(format: "%.1f hours", hours))
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
    }
}

// MARK: - DetailClientSection

/// Client section for incident detail view
struct DetailClientSection: View {
    @Binding var selectedClientId: String?
    let validClients: [Client]
    let onAddNewClient: () -> Void
    let onClientSelected: () async -> Void
    let onNavigateToClient: (Client) -> Void

    private let addNewTag = "ADD_NEW_CLIENT"

    var body: some View {
        Section("Client") {
            AddableClientCell(
                selectedClientId: $selectedClientId,
                validClients: validClients,
                onNavigateToClient: onNavigateToClient
            )
            .onChange(of: selectedClientId) { _, newValue in
                if newValue == addNewTag {
                    onAddNewClient()
                    selectedClientId = nil
                } else if newValue != nil {
                    Task {
                        await onClientSelected()
                    }
                }
            }
        }
    }
}

// MARK: - DetailSurfaceTypeSection

/// Surface type section for incident detail view
struct DetailSurfaceTypeSection: View {
    let surfaceType: SurfaceType?
    let surfaceDisplayName: String
    let customSurfaceDescription: String?

    var body: some View {
        Section("Surface Type") {
            HStack {
                if let surfaceType {
                    Image(systemName: surfaceType.iconName)
                        .foregroundColor(.accentColor)
                        .frame(width: 24)
                }

                VStack(alignment: .leading) {
                    Text(surfaceDisplayName)
                        .font(.headline)

                    if let surfaceType, surfaceType == .other,
                       let customDescription = customSurfaceDescription {
                        Text(customDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
        }
    }
}

// MARK: - DetailLocationSection

/// Location section for incident detail view
struct DetailLocationSection: View {
    let bestLocation: IncidentLocation?
    let onLocationCapture: () -> Void

    var body: some View {
        Section("Location") {
            if let bestLocation {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text(bestLocation.address ?? bestLocation.shortDisplayString)
                            .font(.headline)
                    }

                    if let coordinates = bestLocation.coordinates {
                        Text(coordinates.displayString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Capture Method:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(bestLocation.captureMethod.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let accuracy = bestLocation.accuracy {
                        Text("Accuracy: ±\(Int(accuracy))m")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Button(action: onLocationCapture) {
                    Label("Add Location", systemImage: "location")
                }
            }
        }
    }
}

// MARK: - DetailAreaSection

/// Area section for incident detail view
struct DetailAreaSection: View {
    @Binding var area: Double
    let onSave: () async -> Void

    var body: some View {
        Section("Area (sq ft)") {
            AddableAreaCell(
                area: $area,
                onSave: onSave
            )
        }
    }
}

// MARK: - DetailNotesSection

/// Notes section for incident detail view
struct DetailNotesSection: View {
    let enhancedNotes: IncidentNotes?
    let description: String
    let onDescriptionUpdate: () async -> Void

    var body: some View {
        if let enhancedNotes, enhancedNotes.hasAnyNotes {
            Section("Enhanced Notes") {
                VStack(alignment: .leading, spacing: 12) {
                    if let beforeWork = enhancedNotes.beforeWork, !beforeWork.trimmingCharacters(in: .whitespaces).isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(.blue)
                                Text("Before Work")
                                    .font(.headline)
                            }
                            Text(beforeWork)
                                .font(.body)
                        }
                    }

                    if let duringWork = enhancedNotes.duringWork, !duringWork.trimmingCharacters(in: .whitespaces).isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "hammer.fill")
                                    .foregroundColor(.orange)
                                Text("During Work")
                                    .font(.headline)
                            }
                            Text(duringWork)
                                .font(.body)
                        }
                    }

                    if let completion = enhancedNotes.completion, !completion.trimmingCharacters(in: .whitespaces).isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Completion")
                                    .font(.headline)
                            }
                            Text(completion)
                                .font(.body)
                        }
                    }

                    if let general = enhancedNotes.general, !general.trimmingCharacters(in: .whitespaces).isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.gray)
                                Text("General Notes")
                                    .font(.headline)
                            }
                            Text(general)
                                .font(.body)
                        }
                    }
                }
            }
        } else if !description.trimmingCharacters(in: .whitespaces).isEmpty {
            Section("Description") {
                AddableDescriptionCell(
                    description: .constant(description),
                    onSave: onDescriptionUpdate
                )
            }
        }
    }
}

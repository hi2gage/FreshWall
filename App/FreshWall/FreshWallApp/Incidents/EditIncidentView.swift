@preconcurrency import FirebaseFirestore
import PhotosUI
import SwiftUI

// MARK: - EditIncidentView

/// View for editing an existing incident.
struct EditIncidentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: EditIncidentViewModel
    private let addNewTag = "__ADD_NEW__"

    init(viewModel: EditIncidentViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            // MARK: - Photos Section (Top Priority)

            EditIncidentPhotosSection(
                beforePhotos: $viewModel.beforePhotos,
                afterPhotos: $viewModel.afterPhotos
            )

            // MARK: - Time & Duration Section

            EditTimeStampsSection(
                startTime: $viewModel.startTime,
                endTime: $viewModel.endTime
            )

            // MARK: - Client Selection

            EditClientSelectionSection(
                clientId: $viewModel.clientId,
                validClients: viewModel.validClients,
                addNewTag: addNewTag,
                onClientChange: { newValue in
                    if newValue == addNewTag {
                        // For previews this does nothing. Real usage pushes via router.
                        viewModel.clientId = ""
                    }
                }
            )

            // MARK: - Surface Type Section

            if let surfaceType = viewModel.surfaceType {
                Section("Surface Type") {
                    SurfaceTypeRow(
                        surfaceType: surfaceType,
                        customDescription: viewModel.customSurfaceDescription,
                        onTap: { viewModel.showingSurfaceTypeSelection = true }
                    )
                }
            }

            // MARK: - Location Section

            EditLocationSection(
                enhancedLocation: viewModel.enhancedLocation,
                onLocationCapture: { currentLocation, completion in
                    routerPath.presentLocationCapture(currentLocation: currentLocation, onLocationSelected: { newLocation in
                        viewModel.enhancedLocation = newLocation
                        completion(newLocation)
                    })
                }
            )

            // MARK: - Area Section

            Section("Area (sq ft)") {
                TextField("Area", text: $viewModel.areaText)
                    .keyboardType(.decimalPad)
            }

            // MARK: - Materials Section

            Section("Materials Used") {
                TextEditor(text: $viewModel.materialsUsed)
                    .frame(minHeight: 80)
            }

            // MARK: - Enhanced Notes Section

            if let enhancedNotes = viewModel.enhancedNotes {
                Section("Enhanced Notes") {
                    EnhancedNotesRow(notes: enhancedNotes, onTap: { viewModel.showingEnhancedNotes = true })
                }
            }

            // MARK: - Legacy Description (if no enhanced notes)

            if viewModel.enhancedNotes == nil {
                Section("Description") {
                    TextEditor(text: $viewModel.description)
                        .frame(minHeight: 100)
                }
            }

            // MARK: - Billing Configuration Section

            BillingConfigurationSection(
                hasBillingConfiguration: $viewModel.hasBillingConfiguration,
                billingMethod: $viewModel.billingMethod,
                minimumBillableQuantity: $viewModel.minimumBillableQuantity,
                amountPerUnit: $viewModel.amountPerUnit,
                customUnitDescription: $viewModel.customUnitDescription,
                billingSource: $viewModel.billingSource,
                quantityUnitLabel: viewModel.billingMethod.unitLabel,
                amountUnitLabel: viewModel.billingMethod.unitLabel,
                selectedClientId: viewModel.clientId,
                selectedClient: viewModel.selectedClient
            )

            Section {
                Button("Delete Incident") {
                    viewModel.showingDeleteAlert = true
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Edit Incident")
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
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
            }
        }
        .sheet(isPresented: $viewModel.showingSurfaceTypeSelection) {
            SurfaceTypeSelectionView(
                surfaceType: $viewModel.surfaceType,
                customDescription: $viewModel.customSurfaceDescription
            )
        }
        .sheet(isPresented: $viewModel.showingEnhancedNotes) {
            EnhancedNotesView(notes: $viewModel.enhancedNotes)
        }
        .alert("Delete Incident", isPresented: $viewModel.showingDeleteAlert) {
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
            Text("Are you sure you want to delete this incident? This action cannot be undone.")
        }
        .task {
            await viewModel.loadClients()
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

    func addClient(_: AddClientInput) async throws -> String { "mock-id" }

    func updateClient(_: String, with _: UpdateClientInput) async throws {}

    func deleteClient(_: String) async throws {}
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
    ) async throws -> String { "preview-incident-id" }
    func updateIncident(
        _: String,
        with _: UpdateIncidentInput,
        beforePhotos _: [PickedPhoto],
        afterPhotos _: [PickedPhoto]
    ) async throws {}

    func deleteIncident(_: String) async throws {}
}

// MARK: - EditIncidentPhotosSection

/// Photos section for edit incident view
struct EditIncidentPhotosSection: View {
    @Binding var beforePhotos: [PickedPhoto]
    @Binding var afterPhotos: [PickedPhoto]

    var body: some View {
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
    }
}

// MARK: - EditTimeStampsSection

/// Timestamps section for edit incident view
struct EditTimeStampsSection: View {
    @Binding var startTime: Date
    @Binding var endTime: Date

    var body: some View {
        Section("Timeframe") {
            DatePicker(
                "Start Time",
                selection: $startTime,
                displayedComponents: [.date, .hourAndMinute]
            )
            DatePicker(
                "End Time",
                selection: $endTime,
                displayedComponents: [.date, .hourAndMinute]
            )

            // Show duration
            HStack {
                Text("Duration")
                    .font(.headline)
                Spacer()
                let hours = endTime.timeIntervalSince(startTime) / 3600
                Text(String(format: "%.1f hours", hours))
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
    }
}

// MARK: - EditClientSelectionSection

/// Client selection section for edit incident view
struct EditClientSelectionSection: View {
    @Binding var clientId: String
    let validClients: [(id: String, name: String)]
    let addNewTag: String
    let onClientChange: (String) -> Void

    var body: some View {
        Section("Client") {
            Picker("Select Client", selection: $clientId) {
                Text("Add New Client...").tag(addNewTag)
                ForEach(validClients, id: \.id) { item in
                    Text(item.name).tag(item.id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: clientId) { _, newValue in
                onClientChange(newValue)
            }
        }
    }
}

// MARK: - EditLocationSection

/// Location section for edit incident view
struct EditLocationSection: View {
    let enhancedLocation: IncidentLocation?
    let onLocationCapture: (IncidentLocation?, @escaping (IncidentLocation?) -> Void) -> Void

    var body: some View {
        Section("Location") {
            if let enhancedLocation {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("📍 \(enhancedLocation.address ?? enhancedLocation.shortDisplayString)")
                            .font(.headline)
                        Spacer()
                        Button("Edit") {
                            onLocationCapture(enhancedLocation) { _ in
                                // Update handled by parent through closure
                            }
                        }
                    }

                    Text(enhancedLocation.captureMethod.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Button("📍 Capture Location") {
                    onLocationCapture(nil) { _ in
                        // Update handled by parent through closure
                    }
                }
                .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    let incident = Incident(
        id: "inc1",
        clientRef: Firestore.firestore().document("teams/t/clients/client1"),
        description: "Some incident",
        area: 10,
        location: GeoPoint(latitude: 37.7749, longitude: -122.4194),
        createdAt: .init(),
        startTime: .init(),
        endTime: .init(),
        beforePhotos: [],
        afterPhotos: [],
        createdBy: Firestore.firestore().document("teams/t/users/u"),
        lastModifiedBy: nil,
        lastModifiedAt: nil,
        rate: nil,
        materialsUsed: nil,
        status: .open,
        enhancedLocation: nil,
        surfaceType: nil,
        enhancedNotes: nil,
        customSurfaceDescription: nil
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

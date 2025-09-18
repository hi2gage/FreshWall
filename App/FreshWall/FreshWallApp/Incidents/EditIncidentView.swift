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

    private var shouldShowSquareFootage: Bool {
        // Show if manual override is enabled and billing method is square footage
        if viewModel.hasBillingConfiguration, viewModel.billingSource == .manual {
            return viewModel.billingMethod == .squareFootage
        }
        // Show if client is selected and client's billing method is square footage
        else if let clientId = viewModel.clientId, !clientId.isEmpty, let selectedClient = viewModel.selectedClient {
            return selectedClient.defaults?.billingMethod == .squareFootage
        }
        // Show if no client is selected and no manual override
        else if viewModel.clientId == nil, !viewModel.hasBillingConfiguration {
            return true
        }
        return false
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
                        viewModel.clientId = nil
                    }
                }
            )

            // MARK: - Surface Type Section

            Section("Surface Type") {
                SurfaceTypeSelectionView(
                    surfaceType: $viewModel.surfaceType,
                    customDescription: $viewModel.customSurfaceDescription
                )
            }

            // MARK: - Area Section (conditional based on billing method)

            if shouldShowSquareFootage {
                Section("Area (sq ft)") {
                    TextField("Area", text: $viewModel.areaText)
                        .keyboardType(.decimalPad)
                }
            }

            // MARK: - Location Section

            EditLocationSection(
                enhancedLocation: viewModel.enhancedLocation,
                onLocationCapture: { currentLocation in
                    routerPath.presentLocationCapture(currentLocation: currentLocation, onLocationSelected: { newLocation in
                        viewModel.enhancedLocation = newLocation
                    })
                }
            )

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
    @Binding var clientId: String?
    let validClients: [(id: String, name: String)]
    let addNewTag: String
    let onClientChange: (String?) -> Void

    var body: some View {
        Section("Client") {
            Picker("Select Client", selection: $clientId) {
                Text("Select").tag(nil as String?)
                Text("Add New Client...").tag(addNewTag)
                ForEach(validClients, id: \.id) { item in
                    Text(item.name).tag(item.id as String?)
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
    let onLocationCapture: (IncidentLocation?) -> Void

    var body: some View {
        Section("Location") {
            if let enhancedLocation {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("📍 \(enhancedLocation.address ?? enhancedLocation.shortDisplayString)")
                            .font(.headline)
                        Spacer()
                        Button("Edit") {
                            onLocationCapture(enhancedLocation)
                        }
                    }

                    Text(enhancedLocation.captureMethod.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Button("📍 Capture Location") {
                    onLocationCapture(nil)
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

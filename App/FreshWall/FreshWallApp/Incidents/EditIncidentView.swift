@preconcurrency import FirebaseFirestore
import PhotosUI
import SwiftUI
import os

// MARK: - EditIncidentView

/// View for editing an existing incident.
struct EditIncidentView: View {
    private let logger = Logger.freshWall(category: "EditIncidentView")
    @Environment(\.dismiss) private var dismiss
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: EditIncidentViewModel

    init(viewModel: EditIncidentViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            // MARK: - Photos Section (Top Priority)

            EditablePhotosSection(
                beforePhotos: viewModel.beforePhotos,
                afterPhotos: viewModel.afterPhotos,
                newBeforePhotos: $viewModel.newBeforePhotos,
                newAfterPhotos: $viewModel.newAfterPhotos,
                onDeletePhoto: { photo, isBeforePhoto in
                    viewModel.deletePhoto(photo, isBeforePhoto: isBeforePhoto)
                }
            )

            // MARK: - Time & Duration Section

            EditTimeStampsSection(
                startTime: $viewModel.startTime,
                endTime: $viewModel.endTime
            )

            // MARK: - Client Selection

            ClientSelectionSection(
                clientId: $viewModel.clientId,
                validClients: viewModel.validClients,
                onClientChange: { newValue in
                    if newValue == IncidentFormConstants.addNewClientTag {
                        // For previews this does nothing. Real usage pushes via router.
                        viewModel.clientId = nil
                    }
                }
            )

            // MARK: - Surface Type Section

            SurfaceTypeSection(
                surfaceType: $viewModel.surfaceType,
                customDescription: $viewModel.customSurfaceDescription
            )

            // MARK: - Area Section (conditional based on billing method)

            if viewModel.shouldShowSquareFootage {
                AreaInputSection(areaText: $viewModel.areaText)
            }

            // MARK: - Location Section

            LocationSection(enhancedLocation: $viewModel.enhancedLocation)

            // MARK: - Materials Section

            MaterialsSection(materialsUsed: $viewModel.materialsUsed)

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
        .keyboardDoneToolbar()
        .navigationBarBackButtonHidden(viewModel.hasUnsavedChanges)
        .toolbar {
            if viewModel.hasUnsavedChanges {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showingUnsavedChangesAlert = true
                    }
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        do {
                            try await viewModel.save()
                            dismiss()
                        } catch {
                            logger.error("❌ Error saving incident: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        .interactiveDismissDisabled(viewModel.hasUnsavedChanges)
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
        .alert("Unsaved Changes", isPresented: $viewModel.showingUnsavedChangesAlert) {
            Button("Discard Changes", role: .destructive) {
                dismiss()
            }
            Button("Keep Editing", role: .cancel) {}
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
        }
        .task {
            await viewModel.loadClients()
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

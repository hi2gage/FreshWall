import PhotosUI
import SwiftUI

// MARK: - AddIncidentView

/// View for adding a new incident, injecting a service conforming to `IncidentServiceProtocol`.

struct AddIncidentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RouterPath.self) private var routerPath
    @State var viewModel: AddIncidentViewModel
    @State private var beforePhotos: [PickedPhoto] = []
    @State private var afterPhotos: [PickedPhoto] = []

    /// Initializes the view with a view model.
    init(viewModel: AddIncidentViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            // MARK: - Photos Section (Top Priority)

            IncidentPhotosSection(
                beforePhotos: $beforePhotos,
                afterPhotos: $afterPhotos,
                onPhotosChanged: {
                    viewModel.applyPendingCameraLocation()
                    viewModel.autoPopulateFromPhotos(beforePhotos: beforePhotos, afterPhotos: afterPhotos)
                },
                onCameraSelected: {
                    viewModel.handleCameraSelected()
                },
                onDeletePhoto: { photo, isBeforePhoto in
                    if isBeforePhoto {
                        beforePhotos.removeAll { $0.id == photo.id }
                    } else {
                        afterPhotos.removeAll { $0.id == photo.id }
                    }
                    // Re-trigger auto-populate after deletion
                    viewModel.autoPopulateFromPhotos(beforePhotos: beforePhotos, afterPhotos: afterPhotos)
                }
            )

            // MARK: - Time & Duration Section

            TimeStampsSection(
                startTime: $viewModel.input.startTime,
                endTime: $viewModel.input.endTime,
                showTimeBillingDetails: viewModel.showTimeBillingDetails,
                timeDisplayInfo: viewModel.timeDisplayInfo
            )

            // MARK: - Client Selection

            ClientSelectionSection(
                clientId: $viewModel.input.clientId,
                validClients: viewModel.validClients,
                onClientChange: { newValue in
                    print("🔄 ClientSelectionSection.onClientChange called with: '\(newValue ?? "nil")'")
                    if newValue == IncidentFormConstants.addNewClientTag {
                        print("🔄 Add new client selected, navigating to add client")
                        routerPath.push(.addClient())
                        viewModel.input.clientId = nil
                    } else {
                        print("🔄 Client selected: '\(newValue ?? "nil")', updating billing")
                        viewModel.updateBillingFromClient()
                    }
                }
            )

            // MARK: - Surface Type Section

            SurfaceTypeSection(
                surfaceType: $viewModel.input.surfaceType,
                customDescription: $viewModel.input.customSurfaceDescription
            )

            // MARK: - Area Section (conditional based on billing method)

            if viewModel.shouldShowSquareFootage {
                AreaInputSection(areaText: $viewModel.input.areaText)
            }

            // MARK: - Location Section

            LocationSection(enhancedLocation: $viewModel.input.enhancedLocation)

            // MARK: - Billing Configuration Section

            BillingConfigurationSection(
                hasBillingConfiguration: $viewModel.input.hasBillingConfiguration,
                billingMethod: $viewModel.input.billingMethod,
                minimumBillableQuantity: $viewModel.input.minimumBillableQuantity,
                amountPerUnit: $viewModel.input.amountPerUnit,
                customUnitDescription: $viewModel.input.customUnitDescription,
                billingSource: $viewModel.input.billingSource,
                quantityUnitLabel: viewModel.quantityUnitLabel,
                amountUnitLabel: viewModel.amountUnitLabel,
                selectedClientId: viewModel.input.clientId ?? "",
                selectedClient: viewModel.selectedClient
            )

            // MARK: - Materials Section

            MaterialsSection(materialsUsed: $viewModel.input.materialsUsed)

            // MARK: - Notes Section

            Section("Enhanced Notes") {
                EnhancedNotesRow(notes: viewModel.input.enhancedNotes, onTap: { viewModel.showingEnhancedNotes = true })
            }
        }
        .navigationTitle("Add Incident")
        .keyboardDoneToolbar()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                AsyncButton("Save") {
                    print("🚀 Save button pressed - starting incident creation")
                    print("📊 Form data: clientId=\(viewModel.input.clientId), area=\(viewModel.input.areaText)")
                    print("📸 Photos: before=\(beforePhotos.count), after=\(afterPhotos.count)")
                    print("📍 Location: \(viewModel.input.enhancedLocation?.address ?? "None")")

                    try await viewModel.save(beforePhotos: beforePhotos, afterPhotos: afterPhotos)

                    print("✅ Incident saved successfully, dismissing view")
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $viewModel.showingEnhancedNotes) {
            EnhancedNotesView(notes: $viewModel.input.enhancedNotes)
        }
        .task {
            await viewModel.loadClients()
        }
    }
}

// MARK: - TimeStampsSection

/// Timestamps section with optional time billing display
struct TimeStampsSection: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    let showTimeBillingDetails: Bool
    let timeDisplayInfo: (hours: Double, status: AddIncidentViewModel.TimeStatus, message: String)

    var body: some View {
        Section(header: Text("Timeframe")) {
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

            if showTimeBillingDetails {
                HStack {
                    Text("Duration")
                        .font(.headline)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(timeDisplayInfo.message)
                            .font(.subheadline)
                            .foregroundColor(timeDisplayInfo.status == .sufficient ? .green : .orange)
                        if timeDisplayInfo.status == .belowThreshold {
                            Text("Minimum billing applies")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - BillingConfigurationSection.FocusedField

extension BillingConfigurationSection {
    enum FocusedField: Hashable {
        case minimumQuantity
        case amountPerUnit
    }
}

// MARK: - BillingConfigurationSection

/// Billing configuration section
struct BillingConfigurationSection: View {
    @Binding var hasBillingConfiguration: Bool
    @Binding var billingMethod: IncidentBilling.BillingMethod
    @Binding var minimumBillableQuantity: String
    @Binding var amountPerUnit: String
    @Binding var customUnitDescription: String
    @Binding var billingSource: BillingSource
    let quantityUnitLabel: String
    let amountUnitLabel: String
    let selectedClientId: String?
    let selectedClient: Client?

    @FocusState private var focusedField: BillingConfigurationSection.FocusedField?
    @State private var showManualOverride = false

    private var hasClientDefaults: Bool {
        selectedClient?.defaults != nil
    }

    private var isClientSelected: Bool {
        selectedClientId != nil
    }

    var body: some View {
        Section("Billing Configuration") {
            // OVERRIDE TOGGLE - Always at the top
            VStack(alignment: .leading, spacing: 12) {
                Toggle(showManualOverride ? "Manual Override" : "Override", isOn: $showManualOverride)
                    .foregroundColor(showManualOverride ? .red : .primary)
                    .onChange(of: showManualOverride) { _, newValue in
                        if newValue {
                            hasBillingConfiguration = true
                            billingSource = .manual
                            // Copy client defaults as starting point for override if available
                            if let defaults = selectedClient?.defaults {
                                billingMethod = IncidentBilling.BillingMethod(from: defaults.billingMethod)
                                minimumBillableQuantity = String(defaults.minimumBillableQuantity)
                                amountPerUnit = String(defaults.amountPerUnit)
                            }
                        } else {
                            if isClientSelected, hasClientDefaults {
                                billingSource = .client
                            } else {
                                hasBillingConfiguration = false
                            }
                        }
                    }
            }

            // CONTENT BASED ON STATE
            if showManualOverride {
                // Show manual billing form when override is enabled
                VStack(alignment: .leading, spacing: 8) {
                    Text("Manual Configuration")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else if !isClientSelected {
                Text("Select a client first")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else if !hasClientDefaults {
                Text("Please configure billing defaults in client settings, or use override above")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else {
                // Show client defaults (read-only) when client has defaults
                if let defaults = selectedClient?.defaults {
                    VStack(alignment: .leading, spacing: 12) {
                        // Header with icon
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            VStack(alignment: .leading) {
                                Text("Billing Method")
                                    .font(.headline)
                                Text(defaults.billingMethod.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                // Show time rounding configuration
                                if defaults.billingMethod == .time, let timeRounding = defaults.timeRounding {
                                    Text(timeRounding.displayName)
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                }
                            }
                            Spacer()
                        }

                        // Quantity info
                        HStack {
                            Image(systemName: "number")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            VStack(alignment: .leading) {
                                Text("Minimum Quantity")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(defaults.minimumBillableQuantity, specifier: "%.1f") \(defaults.billingMethod.unitLabel)")
                                    .font(.headline)
                            }
                            Spacer()
                        }

                        // Rate info
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            VStack(alignment: .leading) {
                                Text("Rate")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("$\(defaults.amountPerUnit, specifier: "%.2f")/\(defaults.billingMethod.unitLabel)")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                    }
                }
            }

            // Show billing form when in manual override mode
            if showManualOverride, hasBillingConfiguration {
                billingFormContent
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                if focusedField != nil {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
        .onAppear {
            // Set initial state based on existing configuration
            if hasBillingConfiguration {
                if billingSource == .manual {
                    showManualOverride = true
                } else if isClientSelected, hasClientDefaults {
                    showManualOverride = false
                    billingSource = .client
                }
            } else if isClientSelected, hasClientDefaults {
                // Auto-enable billing from client defaults
                hasBillingConfiguration = true
                billingSource = .client
            }
        }
    }

    @ViewBuilder
    private var billingFormContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Billing Method Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Billing Method")
                    .font(.headline)
                Picker("Billing Method", selection: $billingMethod) {
                    ForEach(IncidentBilling.BillingMethod.allCases, id: \.self) { method in
                        Text(method.displayName).tag(method)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Custom Unit Description (for custom billing method)
            if billingMethod == .custom {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Unit Description")
                        .font(.headline)
                    TextField("Enter unit description (e.g., 'panels', 'sections')", text: $customUnitDescription)
                        .textFieldStyle(.roundedBorder)
                }
            }

            // Minimum Billable Quantity
            VStack(alignment: .leading, spacing: 8) {
                Text("Minimum Billable Quantity")
                    .font(.headline)
                HStack {
                    TextField("0", text: $minimumBillableQuantity)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .minimumQuantity)
                    Text(quantityUnitLabel)
                        .foregroundColor(.secondary)
                }
            }

            // Amount Per Unit
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount Per Unit")
                    .font(.headline)
                HStack {
                    Text("$")
                        .foregroundColor(.secondary)
                    TextField("0.00", text: $amountPerUnit)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .amountPerUnit)
                    Text(amountUnitLabel)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
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

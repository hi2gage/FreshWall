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

    /// Unit label for minimum quantity display
    private var quantityUnitLabel: String {
        if viewModel.input.billingMethod == .custom {
            viewModel.input.customUnitDescription.isEmpty ? "units" : viewModel.input.customUnitDescription
        } else {
            viewModel.input.billingMethod.unitLabel
        }
    }

    /// Unit label for amount per unit display
    private var amountUnitLabel: String {
        if viewModel.input.billingMethod == .custom {
            let customUnit = viewModel.input.customUnitDescription.isEmpty ? "unit" : viewModel.input.customUnitDescription
            return "per \(customUnit)"
        } else {
            return "per \(viewModel.input.billingMethod.unitLabel)"
        }
    }

    /// Whether to show the square footage field
    private var shouldShowSquareFootage: Bool {
        // Show if manual override is enabled and billing method is square footage
        if viewModel.input.hasBillingConfiguration, viewModel.input.billingSource == .manual {
            return viewModel.input.billingMethod == .squareFootage
        }
        // Show if client is selected and client's billing method is square footage
        else if !viewModel.input.clientId.isEmpty, let selectedClient = viewModel.selectedClient {
            return selectedClient.defaults?.billingMethod == .squareFootage
        }
        // Show if no client is selected and no manual override
        else if viewModel.input.clientId.isEmpty, !viewModel.input.hasBillingConfiguration {
            return true
        }
        return false
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
                addNewTag: addNewTag,
                onClientChange: { newValue in
                    print("🔄 ClientSelectionSection.onClientChange called with: '\(newValue)'")
                    if newValue == addNewTag {
                        print("🔄 Add new client selected, navigating to add client")
                        routerPath.push(.addClient())
                        viewModel.input.clientId = ""
                    } else {
                        print("🔄 Client selected: '\(newValue)', updating billing")
                        viewModel.updateBillingFromClient()
                    }
                }
            )

            // MARK: - Surface Type Section

            Section("Surface Type") {
                SurfaceTypeSelectionView(
                    surfaceType: $viewModel.input.surfaceType,
                    customDescription: $viewModel.input.customSurfaceDescription
                )
            }

            // MARK: - Area Section (conditional based on billing method)

            if shouldShowSquareFootage {
                Section("Area (sq ft)") {
                    TextField("Area", text: $viewModel.input.areaText)
                        .keyboardType(.decimalPad)
                }
            }

            // MARK: - Location Section

            LocationSection(
                enhancedLocation: viewModel.input.enhancedLocation,
                onLocationCapture: { currentLocation, completion in
                    routerPath.presentLocationCapture(currentLocation: currentLocation, onLocationSelected: { newLocation in
                        viewModel.input.enhancedLocation = newLocation
                        completion(newLocation)
                    })
                }
            )

            // MARK: - Billing Configuration Section

            BillingConfigurationSection(
                hasBillingConfiguration: $viewModel.input.hasBillingConfiguration,
                billingMethod: $viewModel.input.billingMethod,
                minimumBillableQuantity: $viewModel.input.minimumBillableQuantity,
                amountPerUnit: $viewModel.input.amountPerUnit,
                customUnitDescription: $viewModel.input.customUnitDescription,
                billingSource: $viewModel.input.billingSource,
                quantityUnitLabel: quantityUnitLabel,
                amountUnitLabel: amountUnitLabel,
                selectedClientId: viewModel.input.clientId,
                selectedClient: viewModel.selectedClient
            )

            // MARK: - Materials Section

            Section(header: Text("Materials Used")) {
                TextEditor(text: $viewModel.input.materialsUsed)
                    .frame(minHeight: 80)
            }

            // MARK: - Notes Section

            Section("Enhanced Notes") {
                EnhancedNotesRow(notes: viewModel.input.enhancedNotes, onTap: { viewModel.showingEnhancedNotes = true })
            }
        }
        .navigationTitle("Add Incident")
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

// MARK: - IncidentPhotosSection

/// Photos section with before and after photo pickers
struct IncidentPhotosSection: View {
    @Binding var beforePhotos: [PickedPhoto]
    @Binding var afterPhotos: [PickedPhoto]
    let onPhotosChanged: () -> Void
    let onCameraSelected: () -> Void

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
        PhotoSourcePicker(
            selection: $beforePhotos,
            matching: .images,
            photoLibrary: .shared(),
            onCameraSelected: onCameraSelected
        ) {
            Label("Add Before Photos", systemImage: "photo.on.rectangle")
        }
        .onChange(of: beforePhotos) { _, _ in
            onPhotosChanged()
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
        PhotoSourcePicker(
            selection: $afterPhotos,
            matching: .images,
            photoLibrary: .shared(),
            onCameraSelected: onCameraSelected
        ) {
            Label("Add After Photos", systemImage: "photo.fill.on.rectangle.fill")
        }
        .onChange(of: afterPhotos) { _, _ in
            onPhotosChanged()
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
    let selectedClientId: String
    let selectedClient: Client?

    @FocusState private var focusedField: BillingConfigurationSection.FocusedField?
    @State private var showManualOverride = false

    private var hasClientDefaults: Bool {
        selectedClient?.defaults != nil
    }

    private var isClientSelected: Bool {
        !selectedClientId.isEmpty
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

// MARK: - ClientSelectionSection

/// Client selection section
struct ClientSelectionSection: View {
    @Binding var clientId: String
    let validClients: [(id: String, name: String)]
    let addNewTag: String
    let onClientChange: (String) -> Void

    var body: some View {
        Section(header: Text("Client")) {
            Picker("Select Client", selection: $clientId) {
                Text("Select Client").tag("")
                Text("Add New Client...").tag(addNewTag)
                ForEach(validClients, id: \.id) { item in
                    Text(item.name).tag(item.id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: clientId) { oldValue, newValue in
                print("🔄 ClientSelectionSection Picker.onChange: '\(oldValue)' → '\(newValue)'")
                print("🔄 Available tags: addNewTag='\(addNewTag)', clients=\(validClients.map { "'\($0.id)'" }.joined(separator: ", "))")
                onClientChange(newValue)
            }
        }
        .onAppear {
            print("🔄 ClientSelectionSection.onAppear - clientId: '\(clientId)', validClients count: \(validClients.count)")
        }
    }
}

// MARK: - LocationSection

/// Location capture section
struct LocationSection: View {
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

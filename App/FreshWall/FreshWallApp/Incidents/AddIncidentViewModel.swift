import CoreLocation
@preconcurrency import FirebaseFirestore
import Foundation
import Observation
import Photos
import UniformTypeIdentifiers

// MARK: - IncidentValidationError

/// Validation errors for incident creation
enum IncidentValidationError: LocalizedError {
    case insufficientContent

    var errorDescription: String? {
        switch self {
        case .insufficientContent:
            "Please add at least one photo, location, or note to create an incident."
        }
    }
}

// MARK: - AddIncidentViewModel

/// ViewModel for AddIncidentView, manages form state and saving.
@MainActor
@Observable
final class AddIncidentViewModel {
    /// Container for all editable incident fields.
    struct Input {
        /// Selected client document ID or tag for add-new.
        var clientId: String? {
            didSet {
                print("🔄 AddIncidentViewModel.Input.clientId changed from '\(oldValue ?? "nil")' to '\(clientId ?? "nil")'")
            }
        }

        /// Notes describing the incident.
        var description: String = ""
        /// Area affected as free-form text.
        var areaText: String = ""
        /// Start time of incident.
        var startTime: Date = .init()
        /// End time of incident.
        var endTime: Date = .init()
        /// Billing rate as text.
        var rateText: String = ""
        /// Materials used description.
        var materialsUsed: String = ""

        // MARK: - Enhanced Metadata

        /// Enhanced location data with address and capture method
        var enhancedLocation: IncidentLocation?
        /// Type of surface being worked on
        var surfaceType: SurfaceType?
        /// Structured notes system for different work stages
        var enhancedNotes: IncidentNotes?
        /// Custom surface description when surfaceType is .other
        var customSurfaceDescription: String?

        // MARK: - Billing Configuration

        /// Billing method for this incident
        var billingMethod: IncidentBilling.BillingMethod = .squareFootage
        /// Minimum billable quantity as text
        var minimumBillableQuantity: String = ""
        /// Amount per unit as text
        var amountPerUnit: String = ""
        /// Custom unit description for custom billing method
        var customUnitDescription: String = ""
        /// Whether user has configured billing (auto-populated from client defaults)
        var hasBillingConfiguration: Bool = false
        /// Source of the billing configuration
        var billingSource: BillingSource = .manual
    }

    /// Current input being edited.
    var input = Input()
    /// Loaded clients for selection.
    var clients: [Client] = []
    /// Whether to show the enhanced location capture view.
    var showingEnhancedLocationCapture = false
    /// Whether to show enhanced notes editing.
    var showingEnhancedNotes = false
    /// Pending location captured when camera is selected
    var pendingCameraLocation: IncidentLocation?
    private let clientService: ClientServiceProtocol
    private let service: IncidentServiceProtocol

    /// Validation: requires at least photos, location, or enhanced notes.
    var isValid: Bool {
        // Will be validated with photos in the save method
        true
    }

    init(service: IncidentServiceProtocol, clientService: ClientServiceProtocol) {
        self.service = service
        self.clientService = clientService
    }

    /// Saves the new incident via the service along with photo data.
    func save(beforePhotos: [PickedPhoto], afterPhotos: [PickedPhoto]) async throws {
        // Validate that we have at least photos or location
        let hasPhotos = !beforePhotos.isEmpty || !afterPhotos.isEmpty
        let hasLocation = input.enhancedLocation != nil
        let hasNotes = input.enhancedNotes?.hasAnyNotes == true

        guard hasPhotos || hasLocation || hasNotes else {
            throw IncidentValidationError.insufficientContent
        }

        let areaValue = Double(input.areaText) ?? 0
        let rateValue = Double(input.rateText)
        let trimmedId = input.clientId?.trimmingCharacters(in: .whitespaces)

        // Use enhanced location if available, otherwise extract from photos
        let finalEnhancedLocation = input.enhancedLocation ?? LocationService.extractEnhancedLocation(
            from: beforePhotos,
            afterPhotos: afterPhotos
        )

        // Create billing configuration if configured
        let billingConfig: IncidentBilling? = if input.hasBillingConfiguration {
            IncidentBilling(
                billingMethod: input.billingMethod,
                minimumBillableQuantity: Double(input.minimumBillableQuantity) ?? 0,
                amountPerUnit: Double(input.amountPerUnit) ?? 0,
                billingSource: input.billingSource,
                wasOverridden: billingWasOverridden,
                customUnitDescription: input.billingMethod == .custom ? input.customUnitDescription : nil
            )
        } else {
            nil
        }

        let input = AddIncidentInput(
            clientId: trimmedId?.isEmpty == false ? trimmedId : nil,
            description: input.description,
            area: areaValue,
            startTime: input.startTime,
            endTime: input.endTime,
            rate: rateValue,
            materialsUsed: input.materialsUsed.isEmpty ? nil : input.materialsUsed,
            enhancedLocation: finalEnhancedLocation,
            surfaceType: input.surfaceType,
            enhancedNotes: input.enhancedNotes,
            customSurfaceDescription: input.customSurfaceDescription,
            billing: billingConfig
        )

        // Create the incident first
        print("🚀 Starting incident creation process...")
        print("📝 Input data: clientId=\(input.clientId ?? "nil"), area=\(input.area), photos: before=\(beforePhotos.count), after=\(afterPhotos.count)")

        let incidentId: String
        do {
            print("⏳ Calling service.addIncident...")
            incidentId = try await service.addIncident(
                input,
                beforePhotos: beforePhotos,
                afterPhotos: afterPhotos
            )
            print("✅ Incident created successfully with ID: \(incidentId)")
        } catch {
            print("❌ Failed to create incident: \(error)")
            print("📊 Error type: \(type(of: error))")
            print("📊 Error description: \(error.localizedDescription)")

            if let nsError = error as NSError? {
                print("🔍 NSError domain: \(nsError.domain)")
                print("🔍 NSError code: \(nsError.code)")
                print("🔍 NSError userInfo: \(nsError.userInfo)")
            }

            // Re-throw the error so the UI can handle it
            throw error
        }

        // Save photos to Camera Roll with location metadata
        Task {
            await PhotoLibraryHelper.savePhotosToLibrary(
                beforePhotos: beforePhotos,
                afterPhotos: afterPhotos,
                location: finalEnhancedLocation
            )
        }

        // Queue address resolution for photo locations if location lacks address
        if let location = finalEnhancedLocation,
           location.address == nil,
           let coordinates = location.coordinates {
            ServiceContainer.shared.addressResolutionService.queueAddressResolution(
                for: incidentId,
                coordinates: coordinates
            )
        }
    }

    /// Loads available clients for the picker.
    func loadClients() async {
        clients = await (try? clientService.fetchClients()) ?? []
    }

    /// A list of client options with valid IDs for selection.
    var validClients: [(id: String, name: String)] {
        clients.compactMap { client in
            guard let id = client.id else { return nil }

            return (id: id, name: client.name)
        }
    }

    /// Selected client based on input.clientId
    var selectedClient: Client? {
        clients.first { $0.id == input.clientId }
    }

    /// Auto-populate billing from client defaults when client is selected
    func updateBillingFromClient() {
        print("🔄 updateBillingFromClient called - input.clientId: '\(input.clientId ?? "nil")'")
        print("🔄 selectedClient: \(selectedClient?.name ?? "nil")")

        guard let client = selectedClient,
              let defaults = client.defaults else {
            print("🔄 No client or defaults found, disabling billing configuration")
            input.hasBillingConfiguration = false
            return
        }

        print("🔄 Setting billing from client defaults: \(defaults.billingMethod)")

        // Convert client billing method to incident billing method
        input.billingMethod = IncidentBilling.BillingMethod(from: defaults.billingMethod)
        input.minimumBillableQuantity = String(defaults.minimumBillableQuantity)
        input.amountPerUnit = String(defaults.amountPerUnit)
        input.hasBillingConfiguration = true
    }

    /// Check if billing values were overridden from client defaults
    var billingWasOverridden: Bool {
        guard let client = selectedClient,
              let defaults = client.defaults else {
            return input.hasBillingConfiguration // If no defaults, any config is an override
        }

        let originalMethod = IncidentBilling.BillingMethod(from: defaults.billingMethod)
        let originalQuantity = String(defaults.minimumBillableQuantity)
        let originalAmount = String(defaults.amountPerUnit)

        return input.billingMethod != originalMethod ||
            input.minimumBillableQuantity != originalQuantity ||
            input.amountPerUnit != originalAmount
    }

    // MARK: - Time Calculation

    enum TimeStatus {
        case sufficient
        case belowThreshold
    }

    /// Calculated hours between start and end time
    var calculatedHours: Double {
        input.endTime.timeIntervalSince(input.startTime) / 3600
    }

    /// Time display information for billing
    var timeDisplayInfo: (hours: Double, status: TimeStatus, message: String) {
        let hours = calculatedHours

        // If no billing configuration or not time-based, just show duration
        guard input.hasBillingConfiguration, input.billingMethod == .time else {
            return (hours, .sufficient, String(format: "%.1f hours", hours))
        }

        // Time-based billing: check against threshold
        let minHours = Double(input.minimumBillableQuantity) ?? 0

        if minHours <= 0 {
            // No threshold set, just show duration
            return (hours, .sufficient, String(format: "%.1f hours", hours))
        }

        if hours >= minHours {
            return (hours, .sufficient, String(format: "%.1f hours", hours))
        } else {
            return (minHours, .belowThreshold, String(format: "%.1f hours (threshold not met)", minHours))
        }
    }

    /// Whether to show time-based billing details
    var showTimeBillingDetails: Bool {
        // Show duration by default, with enhanced details for time-based billing
        true
    }

    /// Whether to show square footage billing details
    var showSquareFootageBillingDetails: Bool {
        input.hasBillingConfiguration && input.billingMethod == .squareFootage
    }

    /// Whether to show the square footage field
    var shouldShowSquareFootage: Bool {
        // Show if manual override is enabled and billing method is square footage
        if input.hasBillingConfiguration, input.billingSource == .manual {
            return input.billingMethod == .squareFootage
        }
        // Show if client is selected and client's billing method is square footage
        else if let clientId = input.clientId, !clientId.isEmpty, let selectedClient {
            return selectedClient.defaults?.billingMethod == .squareFootage
        }
        // Show if no client is selected and no manual override
        else if input.clientId == nil, !input.hasBillingConfiguration {
            return true
        }
        return false
    }

    /// Unit label for minimum quantity display
    var quantityUnitLabel: String {
        if input.billingMethod == .custom {
            input.customUnitDescription.isEmpty ? "units" : input.customUnitDescription
        } else {
            input.billingMethod.unitLabel
        }
    }

    /// Unit label for amount per unit display
    var amountUnitLabel: String {
        if input.billingMethod == .custom {
            let customUnit = input.customUnitDescription.isEmpty ? "unit" : input.customUnitDescription
            return "per \(customUnit)"
        } else {
            return "per \(input.billingMethod.unitLabel)"
        }
    }

    // MARK: - Photo Auto-Population

    /// Auto-populates incident data from photo metadata
    func autoPopulateFromPhotos(beforePhotos: [PickedPhoto], afterPhotos: [PickedPhoto]) {
        // Smart timestamp population with fallbacks
        let beforeStartTime = LocationService.extractStartTime(from: beforePhotos)
        let afterEndTime = LocationService.extractEndTime(from: afterPhotos)

        // Auto-populate start time
        if let startTime = beforeStartTime {
            input.startTime = startTime
        } else if afterPhotos.isEmpty, !beforePhotos.isEmpty {
            // Only before photos - use earliest as start, current time as end
            if let fallbackTime = beforePhotos.compactMap(\.captureDate).min() {
                input.startTime = fallbackTime
                input.endTime = Date()
            }
        }

        // Auto-populate end time
        if let endTime = afterEndTime {
            input.endTime = endTime
        } else if beforePhotos.isEmpty, !afterPhotos.isEmpty {
            // Only after photos - use current time as start, latest as end
            if let fallbackTime = afterPhotos.compactMap(\.captureDate).max() {
                input.startTime = Date()
                input.endTime = fallbackTime
            }
        }

        // Ensure start time is before end time
        if input.startTime > input.endTime {
            let temp = input.startTime
            input.startTime = input.endTime
            input.endTime = temp
        }

        // Auto-populate location if not already manually set
        if input.enhancedLocation == nil {
            let extractedLocation = LocationService.extractEnhancedLocation(
                from: beforePhotos,
                afterPhotos: afterPhotos
            )
            input.enhancedLocation = extractedLocation

            // If we found a location from photos but no address, resolve it
            if let location = extractedLocation,
               location.address == nil,
               let coordinates = location.coordinates {
                resolveAddressForLocation(coordinates: coordinates)
            }
        }
    }

    // MARK: - Camera Location Capture

    /// Handles camera selection by capturing location in background
    func handleCameraSelected() {
        Task {
            do {
                var location = try await LocationService.getCurrentLocationOnce()

                // Try to resolve address immediately if we have coordinates
                if let coordinates = location.coordinates {
                    // Check cache first
                    let locationCache = ServiceContainer.shared.locationCache
                    if let cachedAddress = await locationCache.getCachedAddress(for: coordinates) {
                        location.address = cachedAddress
                    } else {
                        // Resolve address in background
                        Task {
                            do {
                                let coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                                let address = try await ModernLocationManager.reverseGeocode(coordinate: coordinate)

                                // Cache the address
                                await locationCache.cacheAddress(address, for: coordinates)

                                // Update location with address
                                await MainActor.run {
                                    if pendingCameraLocation?.coordinates?.latitude == coordinates.latitude,
                                       pendingCameraLocation?.coordinates?.longitude == coordinates.longitude {
                                        pendingCameraLocation?.address = address
                                    }
                                    if input.enhancedLocation?.coordinates?.latitude == coordinates.latitude,
                                       input.enhancedLocation?.coordinates?.longitude == coordinates.longitude {
                                        input.enhancedLocation?.address = address
                                    }
                                }
                            } catch {
                                // Silently continue if address resolution fails
                            }
                        }
                    }
                }

                await MainActor.run {
                    pendingCameraLocation = location
                }
            } catch {
                // Continue without location if it fails
            }
        }
    }

    /// Applies pending camera location when photos are changed
    func applyPendingCameraLocation() {
        if let pendingLocation = pendingCameraLocation {
            input.enhancedLocation = pendingLocation
            pendingCameraLocation = nil
        }
    }

    /// Resolves address for a location with coordinates but no address
    private func resolveAddressForLocation(coordinates: GeoPoint) {
        Task {
            do {
                // Check cache first
                let locationCache = ServiceContainer.shared.locationCache
                if let cachedAddress = await locationCache.getCachedAddress(for: coordinates) {
                    await MainActor.run {
                        if input.enhancedLocation?.coordinates?.latitude == coordinates.latitude,
                           input.enhancedLocation?.coordinates?.longitude == coordinates.longitude {
                            input.enhancedLocation?.address = cachedAddress
                        }
                    }
                } else {
                    // Resolve address in background
                    let coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    let address = try await ModernLocationManager.reverseGeocode(coordinate: coordinate)

                    // Cache the address
                    await locationCache.cacheAddress(address, for: coordinates)

                    // Update location with address
                    await MainActor.run {
                        if input.enhancedLocation?.coordinates?.latitude == coordinates.latitude,
                           input.enhancedLocation?.coordinates?.longitude == coordinates.longitude {
                            input.enhancedLocation?.address = address
                        }
                    }
                }
            } catch {
                // Silently continue if address resolution fails
            }
        }
    }
}

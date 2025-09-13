@preconcurrency import FirebaseFirestore
import Foundation
import Observation

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
        var clientId: String = ""
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
    }

    /// Current input being edited.
    var input = Input()
    /// Loaded clients for selection.
    var clients: [Client] = []
    /// Whether to show the enhanced location capture view.
    var showingEnhancedLocationCapture = false
    /// Whether to show surface type selection.
    var showingSurfaceTypeSelection = false
    /// Whether to show enhanced notes editing.
    var showingEnhancedNotes = false
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
        let trimmedId = input.clientId.trimmingCharacters(in: .whitespaces)

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
                wasOverridden: billingWasOverridden,
                customUnitDescription: input.billingMethod == .custom ? input.customUnitDescription : nil
            )
        } else {
            nil
        }

        let input = AddIncidentInput(
            clientId: trimmedId.isEmpty ? nil : trimmedId,
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
        let incidentId = try await service.addIncident(
            input,
            beforePhotos: beforePhotos,
            afterPhotos: afterPhotos
        )

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
        guard let client = selectedClient,
              let defaults = client.defaults else {
            input.hasBillingConfiguration = false
            return
        }

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
        }
    }
}

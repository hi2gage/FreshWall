import _PhotosUI_SwiftUI
import FirebaseFirestore
import Foundation
import Observation

/// ViewModel for editing an existing incident.
@MainActor
@Observable
final class EditIncidentViewModel {
    // MARK: - State

    /// Represents the complete state of an incident being edited
    struct State: Equatable {
        var clientId: String?
        var description: String
        var areaText: String
        var startTime: Date
        var endTime: Date
        var rateText: String
        var materialsUsed: String
        var existingBeforePhotosCount: Int
        var existingAfterPhotosCount: Int
        var newBeforePhotosCount: Int
        var newAfterPhotosCount: Int
        var photosToDeleteCount: Int
        var enhancedLocation: IncidentLocation?
        var surfaceType: SurfaceType?
        var enhancedNotes: IncidentNotes?
        var customSurfaceDescription: String?
        var hasBillingConfiguration: Bool
        var billingMethod: IncidentBilling.BillingMethod
        var minimumBillableQuantity: String
        var amountPerUnit: String
        var customUnitDescription: String
        var billingSource: BillingSource
    }

    // MARK: - Properties

    /// Selected client document ID.
    var clientId: String?
    /// Notes text.
    var description: String
    /// Area affected input as text.
    var areaText: String
    /// Start time for the incident.
    var startTime: Date
    /// End time for the incident.
    var endTime: Date
    /// Billing rate input as text.
    var rateText: String
    /// Materials used description.
    var materialsUsed: String
    /// Existing before photos from the incident
    private var existingBeforePhotos: [IncidentPhoto] = []
    /// Existing after photos from the incident
    private var existingAfterPhotos: [IncidentPhoto] = []
    /// Newly picked before photos (not yet uploaded)
    var newBeforePhotos: [PickedPhoto] = []
    /// Newly picked after photos (not yet uploaded)
    var newAfterPhotos: [PickedPhoto] = []
    /// Photos marked for deletion (URLs to delete from storage)
    var photosToDelete: [String] = []
    /// Loaded clients for selection.
    var clients: [Client] = []

    /// Combined editable before photos (existing + new)
    var beforePhotos: [EditablePhoto] {
        existingBeforePhotos.map { .existing($0) } + newBeforePhotos.map { .picked($0) }
    }

    /// Combined editable after photos (existing + new)
    var afterPhotos: [EditablePhoto] {
        existingAfterPhotos.map { .existing($0) } + newAfterPhotos.map { .picked($0) }
    }

    /// Whether to show the delete confirmation alert.
    var showingDeleteAlert = false
    /// Whether to show the enhanced location capture view.
    var showingEnhancedLocationCapture = false
    /// Whether to show enhanced notes editing.
    var showingEnhancedNotes = false
    /// Whether to show the unsaved changes alert.
    var showingUnsavedChangesAlert = false

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
    /// Whether user has configured billing
    var hasBillingConfiguration: Bool = false
    /// Source of the billing configuration
    var billingSource: BillingSource = .manual

    private let incidentId: String
    private let service: IncidentServiceProtocol
    private let clientService: ClientServiceProtocol

    // MARK: - State Tracking

    /// Original state when the view was loaded
    private let originalState: State

    /// Current state based on current property values
    var currentState: State {
        State(
            clientId: clientId,
            description: description,
            areaText: areaText,
            startTime: startTime,
            endTime: endTime,
            rateText: rateText,
            materialsUsed: materialsUsed,
            existingBeforePhotosCount: existingBeforePhotos.count,
            existingAfterPhotosCount: existingAfterPhotos.count,
            newBeforePhotosCount: newBeforePhotos.count,
            newAfterPhotosCount: newAfterPhotos.count,
            photosToDeleteCount: photosToDelete.count,
            enhancedLocation: enhancedLocation,
            surfaceType: surfaceType,
            enhancedNotes: enhancedNotes,
            customSurfaceDescription: customSurfaceDescription,
            hasBillingConfiguration: hasBillingConfiguration,
            billingMethod: billingMethod,
            minimumBillableQuantity: minimumBillableQuantity,
            amountPerUnit: amountPerUnit,
            customUnitDescription: customUnitDescription,
            billingSource: billingSource
        )
    }

    /// Check if there are unsaved changes
    var hasUnsavedChanges: Bool {
        currentState != originalState
    }

    /// Validation: requires a client and description.
    var isValid: Bool {
        guard let clientId else { return false }

        return !clientId.trimmingCharacters(in: .whitespaces).isEmpty &&
            !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(
        incident: Incident,
        incidentService: IncidentServiceProtocol,
        clientService: ClientServiceProtocol
    ) {
        // Initialize services first
        incidentId = incident.id ?? ""
        service = incidentService
        self.clientService = clientService

        // Set current values
        clientId = incident.clientRef?.documentID
        description = incident.description
        areaText = String(incident.area)
        startTime = incident.startTime.dateValue()
        endTime = incident.endTime.dateValue()
        rateText = incident.rate.map { String($0) } ?? ""
        materialsUsed = incident.materialsUsed ?? ""

        // Initialize existing photos
        existingBeforePhotos = incident.beforePhotos
        existingAfterPhotos = incident.afterPhotos

        // Initialize enhanced metadata
        enhancedLocation = incident.enhancedLocation
        surfaceType = incident.surfaceType
        enhancedNotes = incident.enhancedNotes
        customSurfaceDescription = incident.customSurfaceDescription

        // Initialize billing configuration
        if let billing = incident.billing {
            hasBillingConfiguration = true
            billingMethod = billing.billingMethod
            minimumBillableQuantity = String(billing.minimumBillableQuantity)
            amountPerUnit = String(billing.amountPerUnit)
            customUnitDescription = billing.customUnitDescription ?? ""
            billingSource = billing.billingSource
        } else {
            hasBillingConfiguration = false
            billingMethod = .squareFootage
            minimumBillableQuantity = ""
            amountPerUnit = ""
            customUnitDescription = ""
            billingSource = .manual
        }

        // Store original state for change tracking
        // Read directly from incident to avoid referencing self before initialization
        if let billing = incident.billing {
            originalState = State(
                clientId: incident.clientRef?.documentID,
                description: incident.description,
                areaText: String(incident.area),
                startTime: incident.startTime.dateValue(),
                endTime: incident.endTime.dateValue(),
                rateText: incident.rate.map { String($0) } ?? "",
                materialsUsed: incident.materialsUsed ?? "",
                existingBeforePhotosCount: incident.beforePhotos.count,
                existingAfterPhotosCount: incident.afterPhotos.count,
                newBeforePhotosCount: 0,
                newAfterPhotosCount: 0,
                photosToDeleteCount: 0,
                enhancedLocation: incident.enhancedLocation,
                surfaceType: incident.surfaceType,
                enhancedNotes: incident.enhancedNotes,
                customSurfaceDescription: incident.customSurfaceDescription,
                hasBillingConfiguration: true,
                billingMethod: billing.billingMethod,
                minimumBillableQuantity: String(billing.minimumBillableQuantity),
                amountPerUnit: String(billing.amountPerUnit),
                customUnitDescription: billing.customUnitDescription ?? "",
                billingSource: billing.billingSource
            )
        } else {
            originalState = State(
                clientId: incident.clientRef?.documentID,
                description: incident.description,
                areaText: String(incident.area),
                startTime: incident.startTime.dateValue(),
                endTime: incident.endTime.dateValue(),
                rateText: incident.rate.map { String($0) } ?? "",
                materialsUsed: incident.materialsUsed ?? "",
                existingBeforePhotosCount: incident.beforePhotos.count,
                existingAfterPhotosCount: incident.afterPhotos.count,
                newBeforePhotosCount: 0,
                newAfterPhotosCount: 0,
                photosToDeleteCount: 0,
                enhancedLocation: incident.enhancedLocation,
                surfaceType: incident.surfaceType,
                enhancedNotes: incident.enhancedNotes,
                customSurfaceDescription: incident.customSurfaceDescription,
                hasBillingConfiguration: false,
                billingMethod: .squareFootage,
                minimumBillableQuantity: "",
                amountPerUnit: "",
                customUnitDescription: "",
                billingSource: .manual
            )
        }
    }

    /// Handles deletion of a photo
    func deletePhoto(_ photo: EditablePhoto, isBeforePhoto: Bool) {
        switch photo {
        case let .existing(incidentPhoto):
            // Remove from existing photos and mark for deletion
            if isBeforePhoto {
                existingBeforePhotos.removeAll { $0.id == incidentPhoto.id }
            } else {
                existingAfterPhotos.removeAll { $0.id == incidentPhoto.id }
            }
            photosToDelete.append(incidentPhoto.url)
        case let .picked(pickedPhoto):
            // Remove from new photos
            if isBeforePhoto {
                newBeforePhotos.removeAll { $0.id == pickedPhoto.id }
            } else {
                newAfterPhotos.removeAll { $0.id == pickedPhoto.id }
            }
        }
    }

    /// Saves the updated incident using the service along with new photos and handles deletions.
    func save() async throws {
        // Use enhanced location if available, otherwise extract from photos
        let finalEnhancedLocation = enhancedLocation ?? {
            if let photoLocation = LocationService.extractLocation(from: newBeforePhotos + newAfterPhotos) {
                return IncidentLocation(photoMetadataCoordinates: photoLocation)
            }
            return nil
        }()

        // Create billing configuration if configured
        let billingConfig: IncidentBilling? = if hasBillingConfiguration {
            IncidentBilling(
                billingMethod: billingMethod,
                minimumBillableQuantity: Double(minimumBillableQuantity) ?? 0,
                amountPerUnit: Double(amountPerUnit) ?? 0,
                billingSource: billingSource,
                wasOverridden: billingWasOverridden,
                customUnitDescription: billingMethod == .custom ? customUnitDescription : nil
            )
        } else {
            nil
        }

        let input = UpdateIncidentInput(
            clientId: clientId?.trimmingCharacters(in: .whitespaces),
            description: description,
            area: Double(areaText) ?? 0,
            startTime: startTime,
            endTime: endTime,
            rate: Double(rateText),
            materialsUsed: materialsUsed.isEmpty ? nil : materialsUsed,
            enhancedLocation: finalEnhancedLocation,
            surfaceType: surfaceType,
            enhancedNotes: enhancedNotes,
            customSurfaceDescription: customSurfaceDescription,
            billing: billingConfig
        )

        try await service.updateIncident(
            incidentId,
            with: input,
            newBeforePhotos: newBeforePhotos,
            newAfterPhotos: newAfterPhotos,
            photosToDelete: photosToDelete
        )
    }

    /// Deletes the incident via the service.
    func delete() async throws {
        try await service.deleteIncident(incidentId)
    }

    /// Loads available clients for selection.
    func loadClients() async {
        clients = await (try? clientService.fetchClients()) ?? []
    }

    /// Valid client options.
    var validClients: [(id: String, name: String)] {
        clients.compactMap { client in
            guard let id = client.id else { return nil }

            return (id: id, name: client.name)
        }
    }

    /// Selected client based on clientId
    var selectedClient: Client? {
        clients.first { $0.id == clientId }
    }

    /// Check if billing values were overridden from client defaults
    var billingWasOverridden: Bool {
        guard let client = selectedClient,
              let defaults = client.defaults else {
            return hasBillingConfiguration // If no defaults, any config is an override
        }

        let originalMethod = IncidentBilling.BillingMethod(from: defaults.billingMethod)
        let originalQuantity = String(defaults.minimumBillableQuantity)
        let originalAmount = String(defaults.amountPerUnit)

        return billingMethod != originalMethod ||
            minimumBillableQuantity != originalQuantity ||
            amountPerUnit != originalAmount
    }

    /// Whether to show the square footage field
    var shouldShowSquareFootage: Bool {
        // Show if manual override is enabled and billing method is square footage
        if hasBillingConfiguration, billingSource == .manual {
            return billingMethod == .squareFootage
        }
        // Show if client is selected and client's billing method is square footage
        else if let clientId, !clientId.isEmpty, let selectedClient {
            return selectedClient.defaults?.billingMethod == .squareFootage
        }
        // Show if no client is selected and no manual override
        else if clientId == nil, !hasBillingConfiguration {
            return true
        }
        return false
    }
}

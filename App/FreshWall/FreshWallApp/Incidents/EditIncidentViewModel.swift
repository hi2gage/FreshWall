import _PhotosUI_SwiftUI
import FirebaseFirestore
import Foundation
import Observation

/// ViewModel for editing an existing incident.
@MainActor
@Observable
final class EditIncidentViewModel {
    /// Selected client document ID.
    var clientId: String
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
    /// Photos selected to represent the "before" state.
    var beforePhotos: [PickedPhoto] = []
    /// Photos selected to represent the "after" state.
    var afterPhotos: [PickedPhoto] = []
    /// Loaded clients for selection.
    var clients: [Client] = []
    /// Whether to show the delete confirmation alert.
    var showingDeleteAlert = false
    /// Whether to show the enhanced location capture view.
    var showingEnhancedLocationCapture = false
    /// Whether to show surface type selection.
    var showingSurfaceTypeSelection = false
    /// Whether to show enhanced notes editing.
    var showingEnhancedNotes = false

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

    /// Validation: requires a client and description.
    var isValid: Bool {
        !clientId.trimmingCharacters(in: .whitespaces).isEmpty &&
            !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(incident: Incident, incidentService: IncidentServiceProtocol, clientService: ClientServiceProtocol) {
        incidentId = incident.id ?? ""
        service = incidentService
        self.clientService = clientService
        clientId = incident.clientRef?.documentID ?? ""
        description = incident.description
        areaText = String(incident.area)
        startTime = incident.startTime.dateValue()
        endTime = incident.endTime.dateValue()
        rateText = incident.rate.map { String($0) } ?? ""
        materialsUsed = incident.materialsUsed ?? ""

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
            billingSource = billing.billingSource
            customUnitDescription = billing.customUnitDescription ?? ""
        } else {
            hasBillingConfiguration = false
        }
    }

    /// Saves the updated incident using the service along with new photos.
    func save(beforePhotos: [PickedPhoto], afterPhotos: [PickedPhoto]) async throws {
        // Use enhanced location if available, otherwise extract from photos
        let finalEnhancedLocation = enhancedLocation ?? {
            if let photoLocation = LocationService.extractLocation(from: beforePhotos + afterPhotos) {
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
            clientId: clientId.trimmingCharacters(in: .whitespaces),
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
            beforePhotos: beforePhotos,
            afterPhotos: afterPhotos
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
}

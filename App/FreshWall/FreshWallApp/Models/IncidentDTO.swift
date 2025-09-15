@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - BillingSource

/// Source of the billing configuration for an incident.
enum BillingSource: String, Codable, Hashable, Sendable {
    case client
    case manual
}

// MARK: - IncidentBilling

/// Billing configuration for a specific incident.
struct IncidentBilling: Codable, Hashable, Sendable {
    /// How this incident should be billed.
    var billingMethod: BillingMethod
    /// Minimum quantity the client will be charged for.
    var minimumBillableQuantity: Double
    /// Amount charged per unit.
    var amountPerUnit: Double
    /// Source of the billing configuration.
    var billingSource: BillingSource
    /// Whether the user overrode client defaults for this incident.
    var wasOverridden: Bool
    /// Custom unit description when using custom billing method.
    var customUnitDescription: String?

    init(
        billingMethod: BillingMethod,
        minimumBillableQuantity: Double,
        amountPerUnit: Double,
        billingSource: BillingSource,
        wasOverridden: Bool = false,
        customUnitDescription: String? = nil
    ) {
        self.billingMethod = billingMethod
        self.minimumBillableQuantity = minimumBillableQuantity
        self.amountPerUnit = amountPerUnit
        self.billingSource = billingSource
        self.wasOverridden = wasOverridden
        self.customUnitDescription = customUnitDescription
    }
}

// MARK: IncidentBilling.BillingMethod

extension IncidentBilling {
    /// Method used to bill this specific incident (includes custom option).
    enum BillingMethod: String, CaseIterable, Codable, Hashable, Sendable {
        case time
        case squareFootage = "square_footage"
        case custom

        var displayName: String {
            switch self {
            case .squareFootage: "Square Footage"
            case .time: "Time"
            case .custom: "Custom"
            }
        }

        var unitLabel: String {
            switch self {
            case .squareFootage: "sq ft"
            case .time: "hours"
            case .custom: "units" // Default, can be overridden
            }
        }

        /// Convert from ClientDTO.BillingMethod to IncidentBilling.BillingMethod
        init(from clientBillingMethod: ClientDTO.BillingMethod) {
            switch clientBillingMethod {
            case .squareFootage: self = .squareFootage
            case .time: self = .time
            }
        }

        /// Check if this method can be converted to a client billing method
        var asClientBillingMethod: ClientDTO.BillingMethod? {
            switch self {
            case .squareFootage: .squareFootage
            case .time: .time
            case .custom: nil // Custom is incident-only
            }
        }
    }
}

// MARK: - IncidentDTO

/// An incident logged for a client, including timestamps, photos, and billing info.
struct IncidentDTO: Codable, Identifiable, Sendable, Hashable {
    /// Firestore-generated document identifier for the incident.
    @DocumentID var id: String?
    /// Reference to the client document associated with this incident, optional when not yet assigned.
    var clientRef: DocumentReference?
    /// Notes describing the incident.
    var description: String
    /// Area affected by the incident.
    var area: Double
    /// Timestamp when the incident record was created.
    var createdAt: Timestamp
    /// Start time of the incident.
    var startTime: Timestamp
    /// End time of the incident.
    var endTime: Timestamp
    /// Metadata for photos taken before work began.
    var beforePhotos: [IncidentPhotoDTO]
    /// Metadata for photos taken after work completed.
    var afterPhotos: [IncidentPhotoDTO]
    /// Reference to the user who created the incident record.
    var createdBy: DocumentReference
    /// Reference to the last user who modified the incident (if applicable).
    var lastModifiedBy: DocumentReference?
    /// Timestamp when the incident was last modified (if applicable).
    var lastModifiedAt: Timestamp?
    /// Optional billing rate applied to this incident.
    var rate: Double?
    /// Materials used during the incident work (optional details).
    var materialsUsed: String?
    /// Current status of the incident
    var status: IncidentStatus?

    // MARK: - Enhanced Metadata

    /// Enhanced location data with address and capture method
    var enhancedLocation: IncidentLocation?
    /// Type of surface being worked on
    var surfaceType: SurfaceType?
    /// Structured notes system for different work stages
    var enhancedNotes: IncidentNotes?
    /// Custom surface description when surfaceType is .other
    var customSurfaceDescription: String?
    /// Billing configuration for this incident
    var billing: IncidentBilling?
}

extension Collection {
    var nullIfEmpty: Self? {
        isEmpty ? nil : self
    }
}

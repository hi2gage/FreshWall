@preconcurrency import FirebaseFirestore
import Foundation

/// Input model for creating a new incident via `IncidentService`.
struct AddIncidentInput: Sendable {
    /// Document ID of the associated client, if one has been selected.
    let clientId: String?
    /// Description of the incident.
    let description: String
    /// Area affected by the incident (sq ft).
    let area: Double
    /// Start time of the incident.
    let startTime: Date
    /// End time of the incident.
    let endTime: Date
    /// Optional rate for billing.
    let rate: Double?
    /// Optional materials used description.
    let materialsUsed: String?

    // MARK: - Enhanced Metadata

    /// Enhanced location data with address and capture method
    let enhancedLocation: IncidentLocation?
    /// Type of surface being worked on
    let surfaceType: SurfaceType?
    /// Structured notes system for different work stages
    let enhancedNotes: IncidentNotes?
    /// Custom surface description when surfaceType is .other
    let customSurfaceDescription: String?
    /// Billing configuration for this incident
    let billing: IncidentBilling?
}

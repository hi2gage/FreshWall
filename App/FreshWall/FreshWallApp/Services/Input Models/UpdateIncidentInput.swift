@preconcurrency import FirebaseFirestore
import Foundation

/// Input model for updating an existing incident via `IncidentService`.
struct UpdateIncidentInput: Sendable {
    /// Document ID of the associated client.
    let clientId: String
    /// Description of the incident.
    let description: String
    /// Area affected by the incident (sq ft).
    let area: Double
    /// Start time of the incident.
    let startTime: Date
    /// End time of the incident.
    let endTime: Date
    /// Whether the incident is billable.
    let billable: Bool
    /// Optional billing rate for the incident.
    let rate: Double?
    /// Optional project name.
    let projectName: String?
    /// Status of the incident (e.g. "open").
    let status: String
    /// Optional materials used description.
    let materialsUsed: String?
}

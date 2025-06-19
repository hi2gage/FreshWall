import Foundation

/// Input model for creating a new incident via `IncidentService`.
struct AddIncidentInput: Sendable {
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
    /// Optional rate for billing.
    let rate: Double?
    /// Optional project name.
    let projectName: String?
    /// Status string (e.g. "open", "completed").
    let status: String
    /// Optional materials used description.
    let materialsUsed: String?
}

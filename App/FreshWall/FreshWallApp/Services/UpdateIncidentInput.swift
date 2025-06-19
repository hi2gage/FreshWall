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
    /// URLs of before photos to remove.
    let removeBeforeUrls: [String]
    /// URLs of after photos to remove.
    let removeAfterUrls: [String]

    init(
        clientId: String,
        description: String,
        area: Double,
        startTime: Date,
        endTime: Date,
        billable: Bool,
        rate: Double?,
        projectName: String?,
        status: String,
        materialsUsed: String?,
        removeBeforeUrls: [String] = [],
        removeAfterUrls: [String] = []
    ) {
        self.clientId = clientId
        self.description = description
        self.area = area
        self.startTime = startTime
        self.endTime = endTime
        self.billable = billable
        self.rate = rate
        self.projectName = projectName
        self.status = status
        self.materialsUsed = materialsUsed
        self.removeBeforeUrls = removeBeforeUrls
        self.removeAfterUrls = removeAfterUrls
    }
}

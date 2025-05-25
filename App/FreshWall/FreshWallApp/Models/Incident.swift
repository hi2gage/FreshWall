import FirebaseFirestore
import Foundation

/// An incident logged for a client, including timestamps, photos, and billing info.
struct Incident: Codable, Identifiable {
    /// Firestore-generated document identifier for the incident.
    @DocumentID var id: String?
    /// Reference to the client document associated with this incident.
    var clientRef: DocumentReference
    /// References to worker user documents involved in this incident.
    var workerRefs: [DocumentReference]
    /// Description of the incident.
    var description: String
    /// Area affected by the incident.
    var area: Double
    /// Timestamp when the incident record was created.
    var createdAt: Timestamp
    /// Start time of the incident.
    var startTime: Timestamp
    /// End time of the incident.
    var endTime: Timestamp
    /// URLs for photos taken before work began.
    var beforePhotoUrls: [String]
    /// URLs for photos taken after work completed.
    var afterPhotoUrls: [String]
    /// Reference to the user who created the incident record.
    var createdBy: DocumentReference
    /// Reference to the last user who modified the incident (if applicable).
    var lastModifiedBy: DocumentReference?
    /// Timestamp when the incident was last modified (if applicable).
    var lastModifiedAt: Timestamp?
    /// Flag indicating whether the incident is billable.
    var billable: Bool
    /// Optional billing rate applied to this incident.
    var rate: Double?
    /// Optional project name associated with this incident.
    var projectName: String?
    /// Current status of the incident (e.g. "open", "in_progress", "completed").
    var status: String
    /// Materials used during the incident work (optional details).
    var materialsUsed: String?
}

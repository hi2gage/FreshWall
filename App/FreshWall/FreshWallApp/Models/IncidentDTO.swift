@preconcurrency import FirebaseFirestore
import Foundation

/// An incident logged for a client, including timestamps, photos, and billing info.
struct IncidentDTO: Codable, Identifiable, Sendable, Hashable {
    /// Firestore-generated document identifier for the incident.
    @DocumentID var id: String?
    /// Title describing the project for this incident.
    var projectTitle: String
    /// Reference to the client document associated with this incident.
    var clientRef: DocumentReference
    /// References to worker user documents involved in this incident.
    var workerRefs: [DocumentReference]
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
    /// Flag indicating whether the incident is billable.
    var billable: Bool
    /// Optional billing rate applied to this incident.
    var rate: Double?
    /// Current status of the incident (e.g. "open", "in_progress", "completed").
    var status: String
    /// Materials used during the incident work (optional details).
    var materialsUsed: String?
}

extension Collection {
    var nullIfEmpty: Self? {
        isEmpty ? nil : self
    }
}

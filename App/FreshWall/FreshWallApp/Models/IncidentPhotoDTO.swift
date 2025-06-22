@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - IncidentPhotoDTO

/// Metadata and storage info for an incident photo persisted in Firestore.
struct IncidentPhotoDTO: Codable, Hashable, Sendable {
    /// Unique identifier for the photo entry.
    var id: String
    /// Download URL for the photo.
    var url: String
    /// When the photo was captured if available.
    var captureDate: Timestamp?
    /// Where the photo was captured if available.
    var location: GeoPoint?
}

extension IncidentPhotoDTO {
    /// Dictionary representation for use with Firestore update operations.
    var dictionary: [String: Any] {
        var dict: [String: Any] = ["id": id, "url": url]
        if let captureDate { dict["captureDate"] = captureDate }
        if let location { dict["location"] = location }
        return dict
    }
}

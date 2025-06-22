import CoreLocation
@preconcurrency import FirebaseFirestore
import Foundation

/// Domain model representing a photo with optional metadata.
struct IncidentPhoto: Hashable, Sendable {
    /// Download URL for the photo.
    var url: String
    /// Date when the photo was captured.
    var captureDate: Date?
    /// Location coordinate where the photo was captured.
    var location: CLLocationCoordinate2D?
}

extension IncidentPhoto {
    /// Create a domain model from a DTO.
    init(dto: IncidentPhotoDTO) {
        url = dto.url
        captureDate = dto.captureDate?.dateValue()
        if let point = dto.location {
            location = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
        } else {
            location = nil
        }
    }

    /// Convert the domain model to a DTO for persistence.
    var dto: IncidentPhotoDTO {
        IncidentPhotoDTO(
            url: url,
            captureDate: captureDate.map { Timestamp(date: $0) },
            location: location.map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) }
        )
    }
}

import CoreLocation
@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - IncidentPhoto

/// Domain model representing a photo with optional metadata.
struct IncidentPhoto: Identifiable, Sendable {
    /// Identifier used to match the DTO representation.
    var id: String
    /// Download URL for the original photo.
    var url: String
    /// Download URL for the thumbnail version.
    var thumbnailUrl: String?
    /// Date when the photo was captured.
    var captureDate: Date?
    /// Location coordinate where the photo was captured.
    var location: CLLocationCoordinate2D?
}

// MARK: Hashable, Equatable

extension IncidentPhoto: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(captureDate)
    }

    static func == (lhs: IncidentPhoto, rhs: IncidentPhoto) -> Bool {
        lhs.url == rhs.url && lhs.captureDate == rhs.captureDate
    }
}

extension IncidentPhoto {
    /// Create a domain model from a DTO.
    init(dto: IncidentPhotoDTO) {
        id = dto.id
        url = dto.url
        thumbnailUrl = dto.thumbnailUrl
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
            id: id,
            url: url,
            thumbnailUrl: thumbnailUrl,
            captureDate: captureDate.map { Timestamp(date: $0) },
            location: location.map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) }
        )
    }
}

import CoreLocation
@preconcurrency import FirebaseFirestore
import Foundation

extension IncidentPhotoDTO {
    /// Create an incident photo DTO from a URL and a ``PickedPhoto``.
    /// - Parameters:
    ///   - url: Storage URL for the photo.
    ///   - photo: The selected photo with metadata.
    init(url: String, photo: PickedPhoto) {
        self.url = url
        self.captureDate = photo.captureDate.map { Timestamp(date: $0) }
        self.location = photo.location.map {
            GeoPoint(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
        }
    }
}

extension Array where Element == PickedPhoto {
    /// Convert the photos into DTOs pairing each item with the given URLs.
    /// - Parameter urls: Storage URLs matching the photo order.
    /// - Returns: DTOs ready for persistence.
    func toIncidentPhotoDTOs(urls: [String]) -> [IncidentPhotoDTO] {
        zip(self, urls).map { photo, url in
            IncidentPhotoDTO(url: url, photo: photo)
        }
    }
}

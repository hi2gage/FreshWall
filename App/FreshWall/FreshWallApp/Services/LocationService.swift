import CoreLocation
@preconcurrency import FirebaseFirestore
import Foundation
import ImageIO
import UIKit

// MARK: - LocationService

/// Service for extracting and managing location data from photos and user input.
struct LocationService: Sendable {
    /// Extracts location from image metadata if available.
    /// - Parameter image: The UIImage to extract location from
    /// - Returns: A GeoPoint if location metadata exists, nil otherwise
    static func extractLocation(from image: UIImage) -> GeoPoint? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else { return nil }
        guard let gpsInfo = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any] else { return nil }
        guard let latitude = gpsInfo[kCGImagePropertyGPSLatitude as String] as? Double,
              let longitude = gpsInfo[kCGImagePropertyGPSLongitude as String] as? Double,
              let latRef = gpsInfo[kCGImagePropertyGPSLatitudeRef as String] as? String,
              let lonRef = gpsInfo[kCGImagePropertyGPSLongitudeRef as String] as? String else {
            return nil
        }

        // Convert to signed coordinates
        let finalLatitude = latRef == "S" ? -latitude : latitude
        let finalLongitude = lonRef == "W" ? -longitude : longitude

        return GeoPoint(latitude: finalLatitude, longitude: finalLongitude)
    }

    /// Extracts enhanced location with potential address from image metadata.
    /// - Parameter image: The UIImage to extract location from
    /// - Returns: An IncidentLocation if location metadata exists, nil otherwise
    static func extractEnhancedLocation(from image: UIImage) -> IncidentLocation? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else { return nil }

        // Extract GPS coordinates
        guard let gpsInfo = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any] else { return nil }
        guard let latitude = gpsInfo[kCGImagePropertyGPSLatitude as String] as? Double,
              let longitude = gpsInfo[kCGImagePropertyGPSLongitude as String] as? Double,
              let latRef = gpsInfo[kCGImagePropertyGPSLatitudeRef as String] as? String,
              let lonRef = gpsInfo[kCGImagePropertyGPSLongitudeRef as String] as? String else {
            return nil
        }

        // Convert to signed coordinates
        let finalLatitude = latRef == "S" ? -latitude : latitude
        let finalLongitude = lonRef == "W" ? -longitude : longitude
        let geoPoint = GeoPoint(latitude: finalLatitude, longitude: finalLongitude)

        // Try to extract address from EXIF UserComment if available
        var extractedAddress: String?
        if let exifInfo = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any],
           let userComment = exifInfo[kCGImagePropertyExifUserComment as String] as? String,
           userComment.hasPrefix("Address: ") {
            extractedAddress = String(userComment.dropFirst("Address: ".count))
        }

        var location = IncidentLocation(photoMetadataCoordinates: geoPoint)
        location.address = extractedAddress
        return location
    }

    /// Extracts location from multiple images, returning the first valid location found.
    /// - Parameter images: Array of UIImages to check
    /// - Returns: A GeoPoint if any image contains location metadata, nil otherwise
    static func extractLocation(from images: [UIImage]) -> GeoPoint? {
        for image in images {
            if let location = extractLocation(from: image) {
                return location
            }
        }
        return nil
    }

    /// Extracts location from PickedPhoto objects.
    /// - Parameter photos: Array of PickedPhoto objects
    /// - Returns: A GeoPoint if any photo contains location metadata, nil otherwise
    static func extractLocation(from photos: [PickedPhoto]) -> GeoPoint? {
        for photo in photos {
            if let location = extractLocation(from: photo.image) {
                return location
            }
        }
        return nil
    }

    /// Converts CLLocationCoordinate2D to GeoPoint for Firestore storage.
    /// - Parameter coordinate: Core Location coordinate
    /// - Returns: Firestore GeoPoint
    static func geoPoint(from coordinate: CLLocationCoordinate2D) -> GeoPoint {
        GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    /// Converts GeoPoint to CLLocationCoordinate2D for use with MapKit.
    /// - Parameter geoPoint: Firestore GeoPoint
    /// - Returns: Core Location coordinate
    static func coordinate(from geoPoint: GeoPoint) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }

    /// Gets current location once using modern API
    @MainActor
    static func getCurrentLocationOnce() async throws -> IncidentLocation {
        try await ModernLocationManager.getCurrentLocationFast()
    }

    /// Alternative method for fitness/activity scenarios (potentially faster)
    @MainActor
    static func getCurrentLocationFitness() async throws -> IncidentLocation {
        try await ModernLocationManager.getCurrentLocationFitness()
    }

    // MARK: - Photo Timestamp Extraction

    /// Extracts the earliest capture date from before photos for start time
    static func extractStartTime(from beforePhotos: [PickedPhoto]) -> Date? {
        let dates = beforePhotos.compactMap(\.captureDate)
        return dates.min()
    }

    /// Extracts the latest capture date from after photos for end time
    static func extractEndTime(from afterPhotos: [PickedPhoto]) -> Date? {
        let dates = afterPhotos.compactMap(\.captureDate)
        return dates.max()
    }

    /// Extracts location from photos, preferring before photos
    /// Returns coordinates immediately; may include pre-resolved address from camera
    static func extractEnhancedLocation(
        from beforePhotos: [PickedPhoto],
        afterPhotos: [PickedPhoto]
    ) -> IncidentLocation? {
        // Try before photos first (incident scene) - check for enhanced location with address
        for photo in beforePhotos {
            if let enhancedLocation = extractEnhancedLocation(from: photo.image) {
                return enhancedLocation
            }
            // Use CLLocation with resolved address if available (camera photos)
            if let clLocation = photo.location {
                let geoPoint = GeoPoint(latitude: clLocation.coordinate.latitude, longitude: clLocation.coordinate.longitude)
                var incidentLocation = IncidentLocation(photoMetadataCoordinates: geoPoint)
                incidentLocation.address = photo.resolvedAddress // ← Use the preserved address!
                return incidentLocation
            }
        }

        // Fall back to after photos - check for enhanced location with address
        for photo in afterPhotos {
            if let enhancedLocation = extractEnhancedLocation(from: photo.image) {
                return enhancedLocation
            }
            // Use CLLocation with resolved address if available (camera photos)
            if let clLocation = photo.location {
                let geoPoint = GeoPoint(latitude: clLocation.coordinate.latitude, longitude: clLocation.coordinate.longitude)
                var incidentLocation = IncidentLocation(photoMetadataCoordinates: geoPoint)
                incidentLocation.address = photo.resolvedAddress // ← Use the preserved address!
                return incidentLocation
            }
        }

        return nil
    }
}

// MARK: - GeoPoint Extensions for Display

extension GeoPoint {
    /// Formatted location string for display purposes.
    var displayString: String {
        String(format: "%.6f, %.6f", latitude, longitude)
    }

    /// Short formatted location string.
    var shortDisplayString: String {
        String(format: "%.4f, %.4f", latitude, longitude)
    }
}

// MARK: - Location Errors

enum LocationError: LocalizedError, Sendable {
    case permissionDenied
    case servicesDisabled
    case timeout
    case geocodingFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "Location permission is required to capture GPS coordinates"
        case .servicesDisabled:
            "Location services are disabled"
        case .timeout:
            "Location request timed out"
        case .geocodingFailed:
            "Unable to determine address from coordinates"
        }
    }
}

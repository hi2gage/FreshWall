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

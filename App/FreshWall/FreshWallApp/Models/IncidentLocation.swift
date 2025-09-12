import CoreLocation
@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - IncidentLocation

/// Enhanced location data for incidents including GPS coordinates, address, and location name
struct IncidentLocation: Codable, Sendable, Hashable {
    /// GPS coordinates
    var coordinates: GeoPoint?
    /// Human-readable address from reverse geocoding
    var address: String?
    /// Custom location name/description provided by user
    var locationName: String?
    /// Whether location was captured automatically or manually entered
    var captureMethod: LocationCaptureMethod
    /// Timestamp when location was captured
    var capturedAt: Date?
    /// Accuracy of GPS reading in meters (nil if manually entered)
    var accuracy: Double?

    enum LocationCaptureMethod: String, Codable, Sendable {
        case gps
        case manual
        case photoMetadata = "photo_metadata"

        var displayName: String {
            switch self {
            case .gps:
                "GPS"
            case .manual:
                "Manual Entry"
            case .photoMetadata:
                "Photo Metadata"
            }
        }
    }

    /// Initializer for GPS-captured location
    init(
        coordinates: GeoPoint,
        address: String? = nil,
        locationName: String? = nil,
        accuracy: Double? = nil
    ) {
        self.coordinates = coordinates
        self.address = address
        self.locationName = locationName
        self.captureMethod = .gps
        self.capturedAt = Date()
        self.accuracy = accuracy
    }

    /// Initializer for manual location entry
    init(
        locationName: String,
        address: String? = nil,
        coordinates: GeoPoint? = nil
    ) {
        self.locationName = locationName
        self.address = address
        self.coordinates = coordinates
        self.captureMethod = .manual
        self.capturedAt = Date()
        self.accuracy = nil
    }

    /// Initializer for photo metadata location
    init(photoMetadataCoordinates: GeoPoint) {
        self.coordinates = photoMetadataCoordinates
        self.captureMethod = .photoMetadata
        self.capturedAt = Date()
        self.accuracy = nil
        self.address = nil
        self.locationName = nil
    }

    /// Display string for location with fallback hierarchy
    var displayString: String {
        if let locationName, !locationName.trimmingCharacters(in: .whitespaces).isEmpty {
            return locationName
        }

        if let address, !address.trimmingCharacters(in: .whitespaces).isEmpty {
            return address
        }

        if let coordinates {
            return coordinates.shortDisplayString
        }

        return "Unknown Location"
    }

    /// Short display string for limited space
    var shortDisplayString: String {
        if let locationName, !locationName.trimmingCharacters(in: .whitespaces).isEmpty {
            let truncated = String(locationName.prefix(25))
            return locationName.count > 25 ? "\(truncated)..." : truncated
        }

        if let coordinates {
            return coordinates.shortDisplayString
        }

        return "No Location"
    }

    /// Whether this location has any meaningful data
    var hasValidData: Bool {
        coordinates != nil ||
            (locationName != nil && !locationName!.trimmingCharacters(in: .whitespaces).isEmpty) ||
            (address != nil && !address!.trimmingCharacters(in: .whitespaces).isEmpty)
    }
}

// MARK: - Legacy GeoPoint Support

extension IncidentLocation {
    /// Creates an IncidentLocation from a legacy GeoPoint for backward compatibility
    init(legacyGeoPoint: GeoPoint) {
        self.coordinates = legacyGeoPoint
        self.captureMethod = .photoMetadata // Assume photo metadata for legacy data
        self.capturedAt = nil
        self.accuracy = nil
        self.address = nil
        self.locationName = nil
    }

    /// Extracts legacy GeoPoint for backward compatibility
    var legacyGeoPoint: GeoPoint? {
        coordinates
    }
}

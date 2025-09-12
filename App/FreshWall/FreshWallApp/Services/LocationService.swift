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

// MARK: - Enhanced Location Manager

/// Observable location manager for real-time GPS capture with permission handling
@MainActor
@Observable
final class EnhancedLocationManager: NSObject, CLLocationManagerDelegate, Sendable {
    private let locationManager = CLLocationManager()

    /// Current location authorization status
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    /// Most recent location reading
    var currentLocation: CLLocation?
    /// Whether location services are actively updating
    var isUpdatingLocation = false
    /// Error message for location issues
    var locationError: String?
    /// Whether reverse geocoding is in progress
    var isGeocodingAddress = false

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
        authorizationStatus = locationManager.authorizationStatus
    }

    /// Requests location permission and starts location updates if granted
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            locationError = "Location access is required to capture incident locations. Please enable location services in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            locationError = "Unknown location authorization status"
        }
    }

    /// Starts location updates
    func startLocationUpdates() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
            locationManager.authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        guard CLLocationManager.locationServicesEnabled() else {
            locationError = "Location services are disabled. Please enable them in Settings."
            return
        }

        isUpdatingLocation = true
        locationError = nil
        locationManager.startUpdatingLocation()
    }

    /// Stops location updates
    func stopLocationUpdates() {
        isUpdatingLocation = false
        locationManager.stopUpdatingLocation()
    }

    /// Gets current location once without continuous updates
    func getCurrentLocationOnce() async throws -> IncidentLocation {
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
            locationManager.authorizationStatus == .authorizedAlways else {
            throw LocationError.permissionDenied
        }
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError.servicesDisabled
        }

        locationManager.requestLocation()

        // Wait for location update with timeout
        for _ in 0 ..< 30 { // 3 second timeout (30 * 0.1s)
            if let location = currentLocation {
                let geoPoint = LocationService.geoPoint(from: location.coordinate)
                return IncidentLocation(
                    coordinates: geoPoint,
                    accuracy: location.horizontalAccuracy
                )
            }
            try await Task.sleep(for: .milliseconds(100))
        }

        throw LocationError.timeout
    }

    /// Reverse geocodes a coordinate to get address
    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> String {
        isGeocodingAddress = true
        defer { isGeocodingAddress = false }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else {
                throw LocationError.geocodingFailed
            }

            return formatAddress(from: placemark)
        } catch {
            throw LocationError.geocodingFailed
        }
    }

    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []

        if let streetNumber = placemark.subThoroughfare {
            addressComponents.append(streetNumber)
        }

        if let streetName = placemark.thoroughfare {
            addressComponents.append(streetName)
        }

        if let city = placemark.locality {
            addressComponents.append(city)
        }

        if let state = placemark.administrativeArea {
            addressComponents.append(state)
        }

        return addressComponents.joined(separator: ", ")
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            currentLocation = location
            locationError = nil

            // Stop continuous updates after getting first location
            if isUpdatingLocation {
                stopLocationUpdates()
            }
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            isUpdatingLocation = false

            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    locationError = "Location access denied. Please enable location services in Settings."
                case .network:
                    locationError = "Network error while getting location. Please check your connection."
                case .locationUnknown:
                    locationError = "Unable to determine location. Please try again."
                default:
                    locationError = "Location error: \(clError.localizedDescription)"
                }
            } else {
                locationError = "Unexpected location error: \(error.localizedDescription)"
            }
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            authorizationStatus = status

            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                locationError = nil
            case .denied, .restricted:
                locationError = "Location access is required to capture incident locations. Please enable location services in Settings."
                isUpdatingLocation = false
            case .notDetermined:
                break
            @unknown default:
                locationError = "Unknown location authorization status"
            }
        }
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

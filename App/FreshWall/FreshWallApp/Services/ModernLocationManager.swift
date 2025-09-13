import CoreLocation
@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - ModernLocationManager

/// Modern location manager using CLLocationUpdate.liveUpdates() for improved performance
@MainActor
final class ModernLocationManager {
    /// Gets current location using the modern CLLocationUpdate API
    static func getCurrentLocationFast() async throws -> IncidentLocation {
        // Check permission first
        let authStatus = CLLocationManager().authorizationStatus
        switch authStatus {
        case .notDetermined:
            // Request permission and wait briefly
            let manager = CLLocationManager()
            manager.requestWhenInUseAuthorization()
            try await Task.sleep(for: .milliseconds(500))
        case .denied, .restricted:
            throw LocationError.permissionDenied
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            throw LocationError.permissionDenied
        }

        // Check if services are enabled
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError.servicesDisabled
        }

        // Use modern live updates API with timeout
        return try await withTimeout(seconds: 3, operation: getLocationFromLiveUpdates)
    }

    /// Internal method to get location from live updates
    private static func getLocationFromLiveUpdates() async throws -> IncidentLocation {
        let updates = CLLocationUpdate.liveUpdates(.default)
        var bestLocation: CLLocation?
        let startTime = Date()

        for try await update in updates {
            // Check for authorization issues
            if update.authorizationDenied || update.authorizationRestricted {
                throw LocationError.permissionDenied
            }

            // Check for service issues
            if #available(iOS 18.0, *) {
                if update.locationUnavailable {
                    throw LocationError.servicesDisabled
                }
            }

            guard let location = update.location else {
                continue
            }

            // Track best location
            if bestLocation == nil || location.horizontalAccuracy < bestLocation!.horizontalAccuracy {
                bestLocation = location
            }

            let timeElapsed = Date().timeIntervalSince(startTime)

            // Return immediately for high accuracy or good accuracy after time
            if location.horizontalAccuracy < 20 ||
                (location.horizontalAccuracy < 65 && timeElapsed > 0.8) {
                let geoPoint = LocationService.geoPoint(from: location.coordinate)
                return IncidentLocation(
                    coordinates: geoPoint,
                    accuracy: location.horizontalAccuracy
                )
            }

            // Accept reasonable accuracy after 1.5 seconds
            if timeElapsed > 1.5, location.horizontalAccuracy < 100 {
                let geoPoint = LocationService.geoPoint(from: location.coordinate)
                return IncidentLocation(
                    coordinates: geoPoint,
                    accuracy: location.horizontalAccuracy
                )
            }

            // Give up after 2.5 seconds and use best location
            if timeElapsed > 2.5, let best = bestLocation, best.horizontalAccuracy < 200 {
                let geoPoint = LocationService.geoPoint(from: best.coordinate)
                return IncidentLocation(
                    coordinates: geoPoint,
                    accuracy: best.horizontalAccuracy
                )
            }
        }

        // Fallback: use best location if we have one
        if let best = bestLocation {
            let geoPoint = LocationService.geoPoint(from: best.coordinate)
            return IncidentLocation(
                coordinates: geoPoint,
                accuracy: best.horizontalAccuracy
            )
        }

        throw LocationError.timeout
    }

    /// Alternative configuration for fitness/activity scenarios (potentially faster)
    static func getCurrentLocationFitness() async throws -> IncidentLocation {
        // Check permission first (same as above)
        let authStatus = CLLocationManager().authorizationStatus
        switch authStatus {
        case .notDetermined:
            let manager = CLLocationManager()
            manager.requestWhenInUseAuthorization()
            try await Task.sleep(for: .milliseconds(500))
        case .denied, .restricted:
            throw LocationError.permissionDenied
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            throw LocationError.permissionDenied
        }

        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError.servicesDisabled
        }

        // Use fitness configuration for potentially faster location fix
        return try await withTimeout(seconds: 2.5, operation: {
            let updates = CLLocationUpdate.liveUpdates(.fitness)

            for try await update in updates {
                if update.authorizationDenied || update.authorizationRestricted {
                    throw LocationError.permissionDenied
                }

                guard let location = update.location,
                      location.horizontalAccuracy < 100 else {
                    continue
                }

                let geoPoint = LocationService.geoPoint(from: location.coordinate)
                return IncidentLocation(
                    coordinates: geoPoint,
                    accuracy: location.horizontalAccuracy
                )
            }

            throw LocationError.timeout
        })
    }

    /// Reverse geocodes a coordinate to get address
    static func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> String {
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

    private static func formatAddress(from placemark: CLPlacemark) -> String {
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
}

// MARK: - Timeout Helper

/// Helper function to add timeout to async operations
private func withTimeout<T: Sendable>(
    seconds: TimeInterval,
    operation: @Sendable @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        // Add the main operation
        group.addTask {
            try await operation()
        }

        // Add timeout task
        group.addTask {
            try await Task.sleep(for: .seconds(seconds))
            throw LocationError.timeout
        }

        // Return first completed result and cancel others
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

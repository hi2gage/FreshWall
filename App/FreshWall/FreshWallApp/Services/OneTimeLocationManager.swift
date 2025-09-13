import CoreLocation
@preconcurrency import FirebaseFirestore
import Foundation

/// Lightweight location manager for one-time GPS capture
@MainActor
final class OneTimeLocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<IncidentLocation, Error>?
    private var bestLocationSoFar: CLLocation?
    private var startTime: Date?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // Faster, still accurate for incident reporting
    }

    /// Requests location permission and gets current location once
    func getCurrentLocation() async throws -> IncidentLocation {
        // Check permission first
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            // Wait for permission response
            try await Task.sleep(for: .milliseconds(500))
        case .denied, .restricted:
            throw LocationError.permissionDenied
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            throw LocationError.permissionDenied
        }

        // Check if services are enabled
        let servicesEnabled = await Task.detached {
            CLLocationManager.locationServicesEnabled()
        }.value

        guard servicesEnabled else {
            throw LocationError.servicesDisabled
        }

        // Request location once with smart timeout
        bestLocationSoFar = nil
        startTime = Date()

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            locationManager.requestLocation()

            // Set a backup timer to return best location after 2 seconds
            Task {
                try? await Task.sleep(for: .seconds(2))
                if let bestLocation = bestLocationSoFar,
                   let continuation = self.continuation,
                   bestLocation.horizontalAccuracy < 100 { // Accept if within 100 meters
                    let geoPoint = LocationService.geoPoint(from: bestLocation.coordinate)
                    let incidentLocation = IncidentLocation(
                        coordinates: geoPoint,
                        accuracy: bestLocation.horizontalAccuracy
                    )
                    self.continuation = nil
                    continuation.resume(returning: incidentLocation)
                }
            }
        }
    }

    /// Reverse geocodes a coordinate to get address
    func reverseGeocode(coordinate: CLLocationCoordinate2D) async throws -> String {
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
            // Keep track of best location
            if bestLocationSoFar == nil || location.horizontalAccuracy < bestLocationSoFar!.horizontalAccuracy {
                bestLocationSoFar = location
            }

            // If we have high accuracy (< 20m) or good accuracy and enough time has passed, return immediately
            let timeElapsed = startTime.map { Date().timeIntervalSince($0) } ?? 0
            if location.horizontalAccuracy < 20 || (location.horizontalAccuracy < 50 && timeElapsed > 1.0) {
                let geoPoint = LocationService.geoPoint(from: location.coordinate)
                let incidentLocation = IncidentLocation(
                    coordinates: geoPoint,
                    accuracy: location.horizontalAccuracy
                )

                continuation?.resume(returning: incidentLocation)
                continuation = nil
            }
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            continuation?.resume(throwing: error)
            continuation = nil
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didChangeAuthorization _: CLAuthorizationStatus) {
        // Handle permission changes if needed
    }
}

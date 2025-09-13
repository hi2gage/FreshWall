import CoreLocation
@preconcurrency import FirebaseFirestore
import MapKit
import SwiftUI

// MARK: - EnhancedLocationCaptureViewModel

@MainActor
@Observable
final class EnhancedLocationCaptureViewModel {
    var capturedLocation: IncidentLocation?
    var locationError: String?
    var isCapturingGPS = false
    var isResolvingAddress = false

    init(initialLocation: IncidentLocation?) {
        self.capturedLocation = initialLocation
    }

    func captureGPSLocation() async {
        isCapturingGPS = true
        locationError = nil

        do {
            // Fast: Get GPS coordinates first (0.5-1 seconds)
            let gpsLocation = try await LocationService.getCurrentLocationOnce()

            // Immediately update UI with coordinates
            capturedLocation = gpsLocation
            isCapturingGPS = false

            // Background: Start address resolution
            if let coordinates = gpsLocation.coordinates {
                Task {
                    await resolveAddressInBackground(for: gpsLocation, coordinates: coordinates)
                }
            }

        } catch {
            locationError = error.localizedDescription
            isCapturingGPS = false
        }
    }

    private func resolveAddressInBackground(for location: IncidentLocation, coordinates: GeoPoint) async {
        isResolvingAddress = true
        defer { isResolvingAddress = false }

        // Check cache first
        if let cachedAddress = LocationCache.shared.getCachedAddress(for: coordinates) {
            await MainActor.run {
                if var current = capturedLocation,
                   current.coordinates == location.coordinates,
                   current.capturedAt == location.capturedAt {
                    current.address = cachedAddress
                    capturedLocation = current
                }
            }
            return
        }

        // Resolve address via geocoding
        let coordinate = LocationService.coordinate(from: coordinates)
        let oneTimeManager = OneTimeLocationManager()

        if let address = try? await oneTimeManager.reverseGeocode(coordinate: coordinate) {
            // Cache the result
            LocationCache.shared.cacheAddress(address, for: coordinates)

            // Update UI if this location is still current
            await MainActor.run {
                if var current = capturedLocation,
                   current.coordinates == location.coordinates,
                   current.capturedAt == location.capturedAt {
                    current.address = address
                    capturedLocation = current
                }
            }
        }
    }

    func updateLocation(_ newLocation: IncidentLocation?) {
        capturedLocation = newLocation
    }
}

// MARK: - EnhancedLocationCaptureView

/// Comprehensive location capture view with GPS, manual entry, and address lookup
struct EnhancedLocationCaptureView: View {
    let onLocationSelected: ((IncidentLocation?) -> Void)?
    @Binding var location: IncidentLocation?
    @Environment(\.dismiss) private var dismiss
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: EnhancedLocationCaptureViewModel

    // Binding-based initializer (existing)
    init(location: Binding<IncidentLocation?>) {
        self.onLocationSelected = nil
        self._location = location
        self._viewModel = State(initialValue: EnhancedLocationCaptureViewModel(initialLocation: location.wrappedValue))
    }

    // Completion-based initializer (new for router navigation)
    init(initialLocation: IncidentLocation?, onLocationSelected: @escaping (IncidentLocation?) -> Void) {
        self.onLocationSelected = onLocationSelected
        self._location = .constant(nil) // Dummy binding since we use completion callback
        self._viewModel = State(initialValue: EnhancedLocationCaptureViewModel(initialLocation: initialLocation))
    }

    var body: some View {
        Form {
            // Current Location Display
            currentLocationSection

            // GPS Capture Section
            gpsCaptureSection

            // Map Selection Section
            mapSelectionSection

            // Error Display
            if let error = viewModel.locationError {
                errorSection(error: error)
            }
        }
        .navigationTitle("Capture Location")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if let onLocationSelected {
                        // Router navigation - use completion callback
                        onLocationSelected(viewModel.capturedLocation)
                    } else {
                        // Sheet navigation - use binding
                        if let capturedLocation = viewModel.capturedLocation {
                            location = capturedLocation
                        }
                    }
                    dismiss()
                }
                .disabled(viewModel.capturedLocation == nil)
            }
        }
    }

    /// Smart location display text based on available data
    private var locationDisplayText: String {
        guard let location = viewModel.capturedLocation else { return "No location" }

        if let address = location.address {
            return address // Full address when available
        } else if let coordinates = location.coordinates {
            return "📍 \(coordinates.displayString)" // Coordinates while waiting
        } else {
            return "Location captured"
        }
    }

    @ViewBuilder
    private var currentLocationSection: some View {
        Section("Current Location") {
            if let location = viewModel.capturedLocation {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(locationDisplayText)
                                .font(.headline)
                            if viewModel.isResolvingAddress {
                                HStack(spacing: 4) {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                    Text("Resolving address...")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        Spacer()
                        Text(location.captureMethod.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let coordinates = location.coordinates {
                        Text(coordinates.displayString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let accuracy = location.accuracy {
                        Text("Accuracy: ±\(Int(accuracy))m")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text("No location selected")
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var gpsCaptureSection: some View {
        Section("GPS Location") {
            Button(action: {
                Task {
                    await viewModel.captureGPSLocation()
                }
            }) {
                HStack {
                    if viewModel.isCapturingGPS {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.blue)
                    }

                    Text(viewModel.isCapturingGPS ? "Capturing GPS Location..." : "Capture Current GPS Location")
                }
            }
            .disabled(viewModel.isCapturingGPS)
        }
    }

    @ViewBuilder
    private var mapSelectionSection: some View {
        Section("Map Selection") {
            Button(action: {
                routerPath.presentMapPicker(currentLocation: viewModel.capturedLocation) { newLocation in
                    viewModel.updateLocation(newLocation)
                }
            }) {
                HStack {
                    Image(systemName: "map")
                        .foregroundColor(.orange)
                    Text("Select on Map")
                }
            }
        }
    }

    @ViewBuilder
    private func errorSection(error: String) -> some View {
        Section {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @State var location: IncidentLocation? = nil

    FreshWallPreview {
        EnhancedLocationCaptureView(location: $location)
    }
}

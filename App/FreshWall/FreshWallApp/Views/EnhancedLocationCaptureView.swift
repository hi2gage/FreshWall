import CoreLocation
@preconcurrency import FirebaseFirestore
import MapKit
import SwiftUI

// MARK: - EnhancedLocationCaptureView

/// Comprehensive location capture view with GPS, manual entry, and address lookup
struct EnhancedLocationCaptureView: View {
    @Binding var location: IncidentLocation?
    @Environment(\.dismiss) private var dismiss
    @State private var locationManager = EnhancedLocationManager()
    @State private var showingManualEntry = false
    @State private var showingMapPicker = false
    @State private var isCapturingGPS = false
    @State private var capturedLocation: IncidentLocation?

    var body: some View {
        NavigationView {
            Form {
                // Current Location Display
                currentLocationSection

                // GPS Capture Section
                gpsCaptureSection

                // Manual Entry Section
                manualEntrySection

                // Map Selection Section
                mapSelectionSection

                // Error Display
                if let error = locationManager.locationError {
                    errorSection(error: error)
                }
            }
            .navigationTitle("Capture Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let capturedLocation {
                            location = capturedLocation
                        }
                        dismiss()
                    }
                    .disabled(capturedLocation == nil)
                }
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualLocationEntryView(location: $capturedLocation)
            }
            .sheet(isPresented: $showingMapPicker) {
                MapLocationPickerView(location: $capturedLocation)
            }
            .onAppear {
                capturedLocation = location
            }
        }
    }

    @ViewBuilder
    private var currentLocationSection: some View {
        Section("Current Location") {
            if let location = capturedLocation {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text(location.displayString)
                            .font(.headline)
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
            Button(action: captureGPSLocation) {
                HStack {
                    if isCapturingGPS {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.blue)
                    }

                    Text(isCapturingGPS ? "Capturing GPS Location..." : "Capture Current GPS Location")
                }
            }
            .disabled(isCapturingGPS || locationManager.authorizationStatus == .denied)

            if locationManager.authorizationStatus == .denied {
                Text("Location permission is required to capture GPS coordinates. Please enable location services in Settings.")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }

    @ViewBuilder
    private var manualEntrySection: some View {
        Section("Manual Entry") {
            Button(action: { showingManualEntry = true }) {
                HStack {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.green)
                    Text("Enter Location Manually")
                }
            }
        }
    }

    @ViewBuilder
    private var mapSelectionSection: some View {
        Section("Map Selection") {
            Button(action: { showingMapPicker = true }) {
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

    private func captureGPSLocation() {
        Task {
            isCapturingGPS = true
            defer { isCapturingGPS = false }

            do {
                let gpsLocation = try await locationManager.getCurrentLocationOnce()

                // Try to get address for the captured location
                if let coordinates = gpsLocation.coordinates {
                    let coordinate = LocationService.coordinate(from: coordinates)
                    let address = try? await locationManager.reverseGeocode(coordinate: coordinate)

                    var enhancedLocation = gpsLocation
                    enhancedLocation.address = address
                    capturedLocation = enhancedLocation
                }
            } catch {
                // Handle error through locationManager.locationError which is observed
            }
        }
    }
}

// MARK: - ManualLocationEntryView

struct ManualLocationEntryView: View {
    @Binding var location: IncidentLocation?
    @Environment(\.dismiss) private var dismiss
    @State private var locationName = ""
    @State private var address = ""
    @State private var coordinatesText = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Location Details") {
                    TextField("Location Name", text: $locationName)
                        .textInputAutocapitalization(.words)

                    TextField("Address", text: $address, axis: .vertical)
                        .textInputAutocapitalization(.words)
                        .lineLimit(2 ... 4)
                }

                Section("Coordinates (Optional)") {
                    TextField("Latitude, Longitude", text: $coordinatesText)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                }

                Section {
                    Text("Enter either a location name, address, or GPS coordinates. Location name is required.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveManualLocation()
                    }
                    .disabled(locationName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveManualLocation() {
        let trimmedName = locationName.trimmingCharacters(in: .whitespaces)
        let trimmedAddress = address.trimmingCharacters(in: .whitespaces)
        let coordinates = parseCoordinates(from: coordinatesText)

        location = IncidentLocation(
            locationName: trimmedName,
            address: trimmedAddress.isEmpty ? nil : trimmedAddress,
            coordinates: coordinates
        )

        dismiss()
    }

    private func parseCoordinates(from text: String) -> GeoPoint? {
        let cleaned = text.trimmingCharacters(in: .whitespaces)
        let components = cleaned.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        guard components.count == 2,
              let latitude = Double(components[0]),
              let longitude = Double(components[1]),
              latitude >= -90, latitude <= 90,
              longitude >= -180, longitude <= 180 else {
            return nil
        }

        return GeoPoint(latitude: latitude, longitude: longitude)
    }
}

// MARK: - MapLocationPickerView

struct MapLocationPickerView: View {
    @Binding var location: IncidentLocation?
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var isGeocodingAddress = false
    @State private var locationManager = EnhancedLocationManager()

    init(location: Binding<IncidentLocation?>) {
        self._location = location

        // Initialize region based on existing location or default to San Francisco
        let initialCoordinate = location.wrappedValue?.coordinates.map(LocationService.coordinate) ??
            CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        self._region = State(initialValue: MKCoordinateRegion(
            center: initialCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))

        self._selectedCoordinate = State(initialValue: location.wrappedValue?.coordinates.map(LocationService.coordinate))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Map(
                    coordinateRegion: $region,
                    interactionModes: .all,
                    showsUserLocation: true,
                    userTrackingMode: .none,
                    annotationItems: annotationItems
                ) { item in
                    MapPin(coordinate: item.coordinate, tint: .red)
                }
                .onTapGesture(coordinateSpace: .local) { _ in
                    selectedCoordinate = region.center
                }

                // Crosshair in center for precise placement
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.red)
                    .allowsHitTesting(false)

                if isGeocodingAddress {
                    VStack {
                        Spacer()
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Looking up address...")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                    }
                }
            }
            .navigationTitle("Select on Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMapLocation()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Use Center") {
                        selectedCoordinate = region.center
                    }
                }
            }
        }
    }

    private var annotationItems: [MapAnnotationItem] {
        guard let coordinate = selectedCoordinate else { return [] }

        return [MapAnnotationItem(coordinate: coordinate)]
    }

    private func saveMapLocation() {
        let finalCoordinate = selectedCoordinate ?? region.center
        let geoPoint = LocationService.geoPoint(from: finalCoordinate)

        // Try to get address for the selected location
        Task {
            isGeocodingAddress = true
            let address = try? await locationManager.reverseGeocode(coordinate: finalCoordinate)

            await MainActor.run {
                location = IncidentLocation(
                    coordinates: geoPoint,
                    address: address
                )
                isGeocodingAddress = false
                dismiss()
            }
        }
    }
}

// MARK: - MapAnnotationItem

private struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Previews

#Preview {
    @State var location: IncidentLocation? = nil

    FreshWallPreview {
        EnhancedLocationCaptureView(location: $location)
    }
}

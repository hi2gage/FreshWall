import CoreLocation
@preconcurrency import FirebaseFirestore
import MapKit
import SwiftUI

// MARK: - MapLocationPickerView

struct MapLocationPickerView: View {
    let initialLocation: IncidentLocation?
    let onLocationSelected: (IncidentLocation) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(RouterPath.self) private var routerPath
    @State private var region: MKCoordinateRegion
    @State private var mapPosition: MapCameraPosition
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedAddress: String?
    @State private var isGeocodingAddress = false
    @State private var isLoadingCurrentLocation = false

    init(initialLocation: IncidentLocation?, onLocationSelected: @escaping (IncidentLocation) -> Void) {
        self.initialLocation = initialLocation
        self.onLocationSelected = onLocationSelected

        // Initialize region based on existing location or default to San Francisco
        let initialCoordinate = initialLocation?.coordinates.map(LocationService.coordinate) ??
            CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        let initialRegion = MKCoordinateRegion(
            center: initialCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )

        self._region = State(initialValue: initialRegion)
        self._mapPosition = State(initialValue: .region(initialRegion))
        self._selectedCoordinate = State(initialValue: initialLocation?.coordinates.map(LocationService.coordinate))
        self._selectedAddress = State(initialValue: initialLocation?.address)
    }

    @Namespace var mapScope

    var body: some View {
        ZStack {
            // Map takes full screen
            MapReader { proxy in
                Map(position: $mapPosition, scope: mapScope) {
                    if let coordinate = selectedCoordinate {
                        Marker("Selected Location", coordinate: coordinate)
                            .tint(.red)
                    }
                    UserAnnotation()
                }
                .onMapCameraChange { context in
                    // Update region when map moves
                    region = MKCoordinateRegion(
                        center: context.region.center,
                        span: context.region.span
                    )
                }
                .onTapGesture { position in
                    // Convert tap position to map coordinate using MapProxy
                    if let coordinate = proxy.convert(position, from: .local) {
                        selectedCoordinate = coordinate
                        // Start geocoding for the new coordinate
                        Task {
                            await geocodeCoordinate(coordinate)
                        }
                    }
                }
            }

            // Floating location button in bottom-right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    MapUserLocationButton(scope: mapScope)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .background(Circle().fill(.regularMaterial))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 120) // Account for bottom toolbar
            }

            // Bottom toolbar
            VStack {
                Spacer()
                bottomToolbar
            }
        }
        .navigationTitle("Select on Map")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    saveMapLocation()
                }
                .disabled(selectedCoordinate == nil)
            }
        }
        .mapScope(mapScope)
        .onAppear {
            // If no initial location, automatically go to current location
            if initialLocation == nil {
                Task {
                    await loadCurrentLocation()
                }
            }
        }
    }

    @ViewBuilder
    private var bottomToolbar: some View {
        VStack(spacing: 0) {
            // Optional: Address preview bar could go here
            if let coordinate = selectedCoordinate {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Selected Location")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if let address = selectedAddress {
                            Text(address)
                                .font(.footnote)
                                .fontWeight(.medium)
                        } else {
                            Text("\(coordinate.latitude, specifier: "%.4f"), \(coordinate.longitude, specifier: "%.4f")")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    if isGeocodingAddress {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }

            // Main bottom bar
            HStack {
                if isLoadingCurrentLocation {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Finding your location...")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Button("Tap to select location") {
                        // Info text - could add help functionality
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .disabled(true)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 2, y: -1)
        }
    }

    @MainActor
    private func geocodeCoordinate(_ coordinate: CLLocationCoordinate2D) async {
        isGeocodingAddress = true
        defer { isGeocodingAddress = false }

        do {
            let oneTimeManager = OneTimeLocationManager()
            let address = try await oneTimeManager.reverseGeocode(coordinate: coordinate)
            selectedAddress = address
        } catch {
            // If geocoding fails, keep coordinates visible
            selectedAddress = nil
            print("Failed to geocode coordinate: \(error)")
        }
    }

    @MainActor
    private func loadCurrentLocation() async {
        isLoadingCurrentLocation = true
        defer { isLoadingCurrentLocation = false }

        do {
            let currentLocation = try await LocationService.getCurrentLocationOnce()
            if let coordinates = currentLocation.coordinates {
                let coordinate = LocationService.coordinate(from: coordinates)

                // Update map position to center on current location
                let newRegion = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )

                withAnimation(.easeInOut(duration: 1.0)) {
                    region = newRegion
                    mapPosition = .region(newRegion)
                }
            }
        } catch {
            // If we can't get current location, keep the default (San Francisco)
            print("Failed to get current location: \(error)")
        }
    }

    private func saveMapLocation() {
        let finalCoordinate = selectedCoordinate ?? region.center
        let geoPoint = LocationService.geoPoint(from: finalCoordinate)

        // Use the already geocoded address if available
        let newLocation = IncidentLocation(
            coordinates: geoPoint,
            address: selectedAddress
        )
        onLocationSelected(newLocation)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    FreshWallPreview {
        MapLocationPickerView(initialLocation: nil) { _ in
            // Preview completion handler
        }
    }
}

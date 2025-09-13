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
    @State private var isGeocodingAddress = false

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
    }

    @Namespace var mapScope

    var body: some View {
        VStack(spacing: 0) {
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
                    }
                }
            }

            // Bottom control bar
            HStack(spacing: 16) {
                Spacer()
                MapUserLocationButton(scope: mapScope)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 2, y: -1)
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
    }

    private func saveMapLocation() {
        let finalCoordinate = selectedCoordinate ?? region.center
        let geoPoint = LocationService.geoPoint(from: finalCoordinate)

        // Try to get address for the selected location
        Task {
            isGeocodingAddress = true
            let oneTimeManager = OneTimeLocationManager()
            let address = try? await oneTimeManager.reverseGeocode(coordinate: finalCoordinate)

            await MainActor.run {
                let newLocation = IncidentLocation(
                    coordinates: geoPoint,
                    address: address
                )
                onLocationSelected(newLocation)
                isGeocodingAddress = false
                dismiss()
            }
        }
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

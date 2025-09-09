@preconcurrency import FirebaseFirestore
import MapKit
import SwiftUI

// MARK: - LocationMapView

/// A map view for selecting and editing incident locations.
struct LocationMapView: View {
    @Binding var location: GeoPoint?
    @Environment(\.dismiss) private var dismiss

    @State private var region: MKCoordinateRegion
    @State private var selectedCoordinate: CLLocationCoordinate2D?

    init(location: Binding<GeoPoint?>) {
        self._location = location

        // Initialize region based on existing location or default to San Francisco
        let initialCoordinate = location.wrappedValue.map(LocationService.coordinate) ??
            CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

        self._region = State(initialValue: MKCoordinateRegion(
            center: initialCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))

        self._selectedCoordinate = State(initialValue: location.wrappedValue.map(LocationService.coordinate))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .none, annotationItems: annotationItems) { item in
                    MapPin(coordinate: item.coordinate, tint: .red)
                }
                .onTapGesture(coordinateSpace: .local) { location in
                    // Convert tap location to coordinate
                    let coordinate = convertTapToCoordinate(tapLocation: location)
                    selectedCoordinate = coordinate
                }

                // Crosshair in center for precise placement
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.red)
                    .allowsHitTesting(false)
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Use center of map as selected location if no pin was placed
                        let finalCoordinate = selectedCoordinate ?? region.center
                        location = LocationService.geoPoint(from: finalCoordinate)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Use Center") {
                        selectedCoordinate = region.center
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    if location != nil {
                        Button("Clear Location") {
                            location = nil
                            selectedCoordinate = nil
                            dismiss()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }

    private var annotationItems: [MapAnnotationItem] {
        guard let coordinate = selectedCoordinate else { return [] }

        return [MapAnnotationItem(coordinate: coordinate)]
    }

    // Helper method to convert tap gesture to coordinate
    // Note: This is a simplified approach - for production you might want to use a more precise method
    private func convertTapToCoordinate(tapLocation _: CGPoint) -> CLLocationCoordinate2D {
        // For now, just use the center of the map when tapped
        // In a real implementation, you'd convert the tap point to a coordinate
        region.center
    }
}

// MARK: - MapAnnotationItem

private struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Preview

#Preview {
    @State var location: GeoPoint? = GeoPoint(latitude: 37.7749, longitude: -122.4194)

    FreshWallPreview {
        LocationMapView(location: $location)
    }
}

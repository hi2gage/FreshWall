import SwiftUI

// MARK: - LocationSection

/// Location capture section for incident forms with integrated router navigation
struct LocationSection: View {
    @Binding var enhancedLocation: IncidentLocation?
    @Environment(RouterPath.self) private var routerPath

    var body: some View {
        Section("Location") {
            if let enhancedLocation {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("📍 \(enhancedLocation.address ?? enhancedLocation.shortDisplayString)")
                            .font(.headline)
                        Spacer()
                        Button("Edit") {
                            handleLocationCapture(currentLocation: enhancedLocation)
                        }
                    }

                    Text(enhancedLocation.captureMethod.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Button("📍 Capture Location") {
                    handleLocationCapture(currentLocation: nil)
                }
            }
        }
    }

    private func handleLocationCapture(currentLocation: IncidentLocation?) {
        routerPath.presentLocationCapture(
            currentLocation: currentLocation,
            onLocationSelected: { newLocation in
                enhancedLocation = newLocation
            }
        )
    }
}

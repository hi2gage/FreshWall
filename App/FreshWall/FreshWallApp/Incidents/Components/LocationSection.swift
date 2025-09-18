import SwiftUI

// MARK: - LocationSection

/// Location capture section for incident forms
struct LocationSection: View {
    let enhancedLocation: IncidentLocation?
    let onLocationCapture: (IncidentLocation?) -> Void

    var body: some View {
        Section("Location") {
            if let enhancedLocation {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("📍 \(enhancedLocation.address ?? enhancedLocation.shortDisplayString)")
                            .font(.headline)
                        Spacer()
                        Button("Edit") {
                            onLocationCapture(enhancedLocation)
                        }
                    }

                    Text(enhancedLocation.captureMethod.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Button("📍 Capture Location") {
                    onLocationCapture(nil)
                }
                .foregroundColor(.blue)
            }
        }
    }
}

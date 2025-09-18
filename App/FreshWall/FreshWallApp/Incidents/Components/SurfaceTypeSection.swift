import SwiftUI

// MARK: - SurfaceTypeSection

/// Surface type selection section for incident forms
struct SurfaceTypeSection: View {
    @Binding var surfaceType: SurfaceType?
    @Binding var customDescription: String?

    var body: some View {
        Section("Surface Type") {
            SurfaceTypeSelectionView(
                surfaceType: $surfaceType,
                customDescription: $customDescription
            )
        }
    }
}

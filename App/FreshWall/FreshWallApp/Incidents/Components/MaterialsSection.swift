import SwiftUI

// MARK: - MaterialsSection

/// Materials used section for incident forms
struct MaterialsSection: View {
    @Binding var materialsUsed: String

    var body: some View {
        Section("Materials Used") {
            TextEditor(text: $materialsUsed)
                .frame(minHeight: 80)
        }
    }
}

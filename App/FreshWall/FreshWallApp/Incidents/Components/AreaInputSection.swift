import SwiftUI

// MARK: - AreaInputSection

/// Area input section for incident forms
struct AreaInputSection: View {
    @Binding var areaText: String

    var body: some View {
        Section("Area (sq ft)") {
            TextField("Area", text: $areaText)
                .keyboardType(.decimalPad)
        }
    }
}

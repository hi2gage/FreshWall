import SwiftUI

struct AddableAreaCell: View {
    @Binding var area: Double
    let onSave: () async -> Void

    var body: some View {
        InlineEditableField(
            title: "Square Footage",
            value: area > 0 ? area : nil,
            unit: "sq ft",
            onSave: { newValue in
                area = newValue
                await onSave()
            }
        )
    }
}

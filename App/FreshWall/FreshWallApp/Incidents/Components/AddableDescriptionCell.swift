import SwiftUI

struct AddableDescriptionCell: View {
    @Binding var description: String
    let onSave: () async -> Void

    var body: some View {
        InlineEditableTextEditor(
            title: "Description",
            text: $description,
            onSave: onSave
        )
    }
}

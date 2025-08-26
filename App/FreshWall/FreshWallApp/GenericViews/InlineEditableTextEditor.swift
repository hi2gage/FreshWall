import SwiftUI

struct InlineEditableTextEditor: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let onSave: () async -> Void
    let minHeight: CGFloat

    @State private var isEditing = false
    @State private var editingText = ""
    @FocusState private var isFieldFocused: Bool

    var isEditable: Bool {
        text.isEmpty
    }

    init(
        title: String,
        text: Binding<String>,
        placeholder: String = "",
        minHeight: CGFloat = 80,
        onSave: @escaping () async -> Void
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder.isEmpty ? "Add \(title)" : placeholder
        self.minHeight = minHeight
        self.onSave = onSave
    }

    var body: some View {
        if !text.isEmpty, !isEditing {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text(text)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                startEditing()
            }
        } else if isEditing {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                TextEditor(text: $editingText)
                    .focused($isFieldFocused)
                    .frame(minHeight: minHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button("Cancel") {
                                cancelEditing()
                            }
                            Spacer()
                            Button("Save") {
                                saveValue()
                            }
                            .fontWeight(.semibold)
                            .disabled(editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
            }
        } else {
            Button("Add \(title)") {
                startEditing()
            }
        }
    }

    private func startEditing() {
        guard isEditable else { return }

        isEditing = true
        editingText = text
        isFieldFocused = true
    }

    private func cancelEditing() {
        isEditing = false
        editingText = ""
        isFieldFocused = false
    }

    private func saveValue() {
        let trimmed = editingText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        Task {
            text = trimmed
            await onSave()
            isEditing = false
            isFieldFocused = false
        }
    }
}

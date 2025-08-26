import SwiftUI

// MARK: - InlineEditableSelector

// struct AddableClientCell: View {
//    @Binding var selectedClientId: String?
//    let onSave: () async -> Void
//
//    var body: some View {
//        if let client {
//            HStack {
//                Button(client.name) {
//                    routerPath.push(.clientDetail(client: client))
//                }
//                Spacer()
//                Button(action: { showingClientPicker = true }) {
//                    Image(systemName: "pencil")
//                        .foregroundColor(.accentColor)
//                }
//            }
//        } else {
//            Button("Add Client") {
//                showingClientPicker = true
//            }
//        }
//    }
// }

struct InlineEditableSelector<Value>: View {
    let title: String
    let value: Value?
    let placeholder: String
    let formatter: (Value) -> String
    let parser: (String) -> Value?
    let validator: (String) -> Bool
    let onSave: (Value) async -> Void
    let keyboardType: UIKeyboardType

    @State private var isEditing = false
    @State private var editingText = ""
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        if let value, !isEditing {
            HStack {
                Text(title)
                Spacer()
                Text(formatter(value))
            }
        } else if isEditing {
            HStack {
                TextField(placeholder, text: $editingText)
                    .keyboardType(keyboardType)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFieldFocused)
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
                            .disabled(!validator(editingText))
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
        isEditing = true
        editingText = value.map { formatter($0) } ?? ""
        isFieldFocused = true
    }

    private func cancelEditing() {
        isEditing = false
        editingText = ""
        isFieldFocused = false
    }

    private func saveValue() {
        guard let newValue = parser(editingText) else { return }

        Task {
            await onSave(newValue)
            isEditing = false
            isFieldFocused = false
        }
    }
}

// Convenience initializer for Double values with units
extension InlineEditableSelector where Value == Double {
    init(
        title: String,
        value: Double?,
        placeholder: String = "",
        unit: String? = nil,
        onSave: @escaping (Double) async -> Void
    ) {
        self.init(
            title: title,
            value: value,
            placeholder: placeholder.isEmpty ? title : placeholder,
            formatter: { val in
                let formatted = String(format: "%.2f", val)
                return unit != nil ? "\(formatted) \(unit!)" : formatted
            },
            parser: { Double($0) },
            validator: { Double($0) != nil },
            onSave: onSave,
            keyboardType: .decimalPad
        )
    }
}

// Convenience initializer for String values
extension InlineEditableSelector where Value == String {
    init(
        title: String,
        value: String?,
        placeholder: String = "",
        onSave: @escaping (String) async -> Void
    ) {
        self.init(
            title: title,
            value: value,
            placeholder: placeholder.isEmpty ? title : placeholder,
            formatter: { $0 },
            parser: { $0 },
            validator: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            onSave: onSave,
            keyboardType: .default
        )
    }
}

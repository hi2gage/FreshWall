@preconcurrency import FirebaseFirestore
import PhotosUI
import SwiftUI

// MARK: - InlineTextEditor

struct InlineTextEditor: View {
    @Binding var isPresented: Bool
    @Binding var text: String
    let title: String
    let onSave: () async -> Void
    @State private var editingText: String = ""
    @State private var isSaving = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                TextField(title, text: $editingText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTextFieldFocused)
            }
            .navigationTitle("Edit \(title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            isSaving = true
                            text = editingText
                            await onSave()
                            isSaving = false
                            isPresented = false
                        }
                    }
                    .disabled(isSaving || editingText.isEmpty)
                }
            }
            .disabled(isSaving)
        }
        .onAppear {
            editingText = text
            isTextFieldFocused = true
        }
    }
}

// MARK: - InlineNumberEditor

struct InlineNumberEditor: View {
    @Binding var isPresented: Bool
    @Binding var value: Double
    let title: String
    let onSave: () async -> Void
    @State private var editingValue: String = ""
    @State private var isSaving = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    TextField(title, text: $editingValue)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                    Text("sq ft")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Edit \(title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if let doubleValue = Double(editingValue) {
                                isSaving = true
                                value = doubleValue
                                await onSave()
                                isSaving = false
                                isPresented = false
                            }
                        }
                    }
                    .disabled(isSaving || Double(editingValue) == nil)
                }
            }
            .disabled(isSaving)
        }
        .onAppear {
            editingValue = value > 0 ? String(format: "%.2f", value) : ""
            isTextFieldFocused = true
        }
    }
}

// MARK: - InlinePhotoPicker

struct InlinePhotoPicker: View {
    @Binding var isPresented: Bool
    @Binding var photos: [IncidentPhoto]
    let title: String
    let onSave: () async -> Void
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            VStack {
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 10,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                if !selectedItems.isEmpty {
                    Text("\(selectedItems.count) photo(s) selected")
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            isSaving = true
                            // In a real implementation, you would upload photos here
                            // For now, we'll create placeholder photos
                            let newPhotos = selectedItems.enumerated().map { index, _ in
                                IncidentPhoto(
                                    id: UUID().uuidString,
                                    url: "https://placeholder.com/photo\(index)",
                                    captureDate: Date(),
                                    location: nil
                                )
                            }
                            photos.append(contentsOf: newPhotos)
                            await onSave()
                            isSaving = false
                            isPresented = false
                        }
                    }
                    .disabled(isSaving || selectedItems.isEmpty)
                }
            }
            .disabled(isSaving)
        }
    }
}

// MARK: - InlineClientPicker

struct InlineClientPicker: View {
    @Binding var isPresented: Bool
    @Binding var selectedClientId: String?
    let clients: [Client]
    let onSave: () async -> Void
    @State private var tempSelectedId: String? = nil
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(clients) { client in
                    HStack {
                        Text(client.name)
                        Spacer()
                        if tempSelectedId == client.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        tempSelectedId = client.id
                    }
                }
            }
            .navigationTitle("Select Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if let selectedId = tempSelectedId {
                                isSaving = true
                                selectedClientId = selectedId
                                await onSave()
                                isSaving = false
                                isPresented = false
                            }
                        }
                    }
                    .disabled(isSaving || tempSelectedId == nil)
                }
            }
            .disabled(isSaving)
        }
        .onAppear {
            tempSelectedId = selectedClientId
        }
    }
}

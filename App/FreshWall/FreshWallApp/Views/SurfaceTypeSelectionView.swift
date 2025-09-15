import SwiftUI

// MARK: - SurfaceTypeSelectionView

/// View for selecting surface type with custom description support
struct SurfaceTypeSelectionView: View {
    @Binding var surfaceType: SurfaceType?
    @Binding var customDescription: String?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: SurfaceType = .concrete
    @State private var customText = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Surface Type") {
                    ForEach(SurfaceType.allCases, id: \.self) { type in
                        Button(action: { selectedType = type }) {
                            HStack {
                                Image(systemName: type.iconName)
                                    .foregroundColor(selectedType == type ? .white : .accentColor)
                                    .frame(width: 24)

                                Text(type.displayName)
                                    .foregroundColor(selectedType == type ? .white : .primary)

                                Spacer()

                                if selectedType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .listRowBackground(
                            selectedType == type ? Color.accentColor : Color.clear
                        )
                    }
                }

                if selectedType == .other {
                    Section("Custom Description") {
                        TextField("Describe the surface...", text: $customText, axis: .vertical)
                            .textInputAutocapitalization(.sentences)
                            .lineLimit(2 ... 4)
                    }
                }

                Section {
                    Text("Select the primary surface type being worked on. This helps track materials and techniques used.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Surface Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        surfaceType = selectedType
                        customDescription = selectedType == .other && !customText.trimmingCharacters(in: .whitespaces).isEmpty ? customText : nil
                        dismiss()
                    }
                    .disabled(selectedType == .other && customText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            if let currentType = surfaceType {
                selectedType = currentType
                customText = customDescription ?? ""
            }
        }
    }
}

// MARK: - SurfaceTypeRow

/// Compact row for displaying surface type in forms
struct SurfaceTypeRow: View {
    let surfaceType: SurfaceType?
    let customDescription: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                if let surfaceType {
                    Image(systemName: surfaceType.iconName)
                        .foregroundColor(.accentColor)
                        .frame(width: 24)

                    VStack(alignment: .leading) {
                        Text(surfaceType.displayName)
                            .foregroundColor(.primary)

                        if surfaceType == .other, let custom = customDescription, !custom.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text(custom)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                } else {
                    Image(systemName: "questionmark.square")
                        .foregroundColor(.secondary)
                        .frame(width: 24)
                    Text("Select Surface Type")
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var surfaceType: SurfaceType? = .concrete
    @State var customDescription: String? = nil

    FreshWallPreview {
        NavigationStack {
            SurfaceTypeSelectionView(
                surfaceType: $surfaceType,
                customDescription: $customDescription
            )
        }
    }
}

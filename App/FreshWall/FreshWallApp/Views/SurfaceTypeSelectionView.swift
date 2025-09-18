import SwiftUI

// MARK: - SurfaceTypeSelectionView

/// Dropdown view for selecting surface type with custom description support
struct SurfaceTypeSelectionView: View {
    @Binding var surfaceType: SurfaceType?
    @Binding var customDescription: String?
    @State private var customText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Main picker to match Client selection styling
            Picker("Surface Type", selection: $surfaceType) {
                Text("Select").tag(nil as SurfaceType?)
                ForEach(SurfaceType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type as SurfaceType?)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: surfaceType) { _, newValue in
                if newValue != .other {
                    customDescription = nil
                    customText = ""
                } else {
                    customText = customDescription ?? ""
                }
            }

            // Custom description field for "other" surface type
            if surfaceType == .other {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Description")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("Describe the surface...", text: $customText, axis: .vertical)
                        .textInputAutocapitalization(.sentences)
                        .lineLimit(2 ... 4)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: customText) { _, newValue in
                            customDescription = newValue.trimmingCharacters(in: .whitespaces).isEmpty ? nil : newValue
                        }
                }
            }
        }
        .onAppear {
            if let currentType = surfaceType {
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
    @Previewable @State var customDescription: String? = nil

    FreshWallPreview {
        Form {
            Section("Surface Configuration") {
                SurfaceTypeSelectionView(
                    surfaceType: $surfaceType,
                    customDescription: $customDescription
                )
            }
        }
    }
}

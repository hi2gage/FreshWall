import SwiftUI

// MARK: - SurfaceTypeSelectionView

/// Dropdown view for selecting surface type with custom description support
struct SurfaceTypeSelectionView: View {
    @Binding var surfaceType: SurfaceType?
    @Binding var customDescription: String?
    @State private var customText = ""

    private var selectedDisplayText: String {
        if let surfaceType {
            surfaceType.displayName
        } else {
            "Select Surface Type"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("Surface Type:")
                    .foregroundColor(.primary)

                Menu {
                    Button("None") {
                        surfaceType = nil
                        customDescription = nil
                        customText = ""
                    }

                    ForEach(SurfaceType.allCases, id: \.self) { type in
                        Button {
                            surfaceType = type
                            if type != .other {
                                customDescription = nil
                                customText = ""
                            } else {
                                customText = customDescription ?? ""
                            }
                        } label: {
                            HStack {
                                Image(systemName: type.iconName)
                                Text(type.displayName)
                            }
                        }
                    }
                } label: {
                    HStack {
                        if let surfaceType {
                            Image(systemName: surfaceType.iconName)
                                .foregroundColor(.accentColor)
                                .frame(width: 16)
                        }
                        Text(selectedDisplayText)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
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

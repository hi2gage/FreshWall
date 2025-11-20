import SwiftUI

// MARK: - WhatsNewView

struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss

    let version: String
    let updates: [WhatsNewItem]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's New")
                            .font(.largeTitle)
                            .bold()

                        Text("Version \(version)")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Updates list
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(updates) { item in
                            HStack(alignment: .top, spacing: 16) {
                                Image(systemName: item.icon)
                                    .font(.title2)
                                    .foregroundStyle(item.color)
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.headline)

                                    Text(item.description)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - WhatsNewItem

struct WhatsNewItem: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let description: String
}

// MARK: - Version Configuration

extension WhatsNewView {
    /// Returns the current app version
    static var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    /// Checks if user has seen what's new for current version
    static var shouldShowWhatsNew: Bool {
        let lastSeenVersion = UserDefaults.standard.string(forKey: "lastSeenWhatsNewVersion")
        return lastSeenVersion != currentVersion
    }

    /// Marks current version as seen
    static func markWhatsNewAsSeen() {
        UserDefaults.standard.set(currentVersion, forKey: "lastSeenWhatsNewVersion")
    }

    /// Updates for version 1.3.0
    static var version130Updates: [WhatsNewItem] {
        [
            WhatsNewItem(
                icon: "photo.stack.fill",
                color: .blue,
                title: "Faster Photos",
                description: "Photo loading and caching has been dramatically improved for a smoother experience"
            ),
            WhatsNewItem(
                icon: "paintpalette.fill",
                color: .orange,
                title: "New Color Scheme",
                description: "Fresh new colors throughout the app"
            ),
        ]
    }
}

// MARK: - Preview

#Preview {
    FreshWallPreview {
        WhatsNewView(
            version: "1.3.0",
            updates: WhatsNewView.version130Updates
        )
    }
}

import SwiftUI

struct SettingsView: View {
    let sessionStore: AuthenticatedSessionStore
    @State private var showingDebugMenu = false

    var body: some View {
        List {
            // User Section
            Section(header: Text("Account")) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                    VStack(alignment: .leading) {
                        Text(sessionStore.session.displayName)
                            .font(.headline)
                        Text("Team Member")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)

                Button(action: {
                    sessionStore.logout()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("Log Out")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }

            // Team Section
            Section(header: Text("Team")) {
                HStack {
                    Image(systemName: "building.2")
                        .foregroundColor(.green)
                    Text("Team ID")
                    Spacer()
                    Text(sessionStore.session.teamId)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }

            // App Section
            Section(header: Text("App")) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("Version")
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "hammer.circle")
                        .foregroundColor(.orange)
                    Text("Build")
                    Spacer()
                    Text(buildNumber)
                        .foregroundColor(.secondary)
                }
            }

            #if DEBUG
                // Debug Section
                Section(header: Text("Debug")) {
                    Button(action: {
                        showingDebugMenu = true
                    }) {
                        HStack {
                            Image(systemName: "gear.badge")
                                .foregroundColor(.orange)
                            Text("Debug Settings")
                            Spacer()
                            Text(FirebaseConfiguration.currentEnvironment.description)
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                }
            #endif
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDebugMenu) {
            DebugMenuView()
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            SettingsView(
                sessionStore: AuthenticatedSessionStore(
                    sessionStore: SessionStore(),
                    session: UserSession(
                        userId: "user123",
                        displayName: "John Doe",
                        teamId: "team123"
                    )
                )
            )
        }
    }
}

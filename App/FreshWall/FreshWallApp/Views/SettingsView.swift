import SwiftUI

// MARK: - EnvironmentType

enum EnvironmentType: String, CaseIterable {
    case firebase = "Firebase"
    case localhost = "Localhost"
    case customIP = "Custom IP"

    var description: String { rawValue }

    var emulatorEnvironment: EmulatorEnvironment? {
        switch self {
        case .localhost: .localhost
        case .customIP: .customIP
        case .firebase: nil
        }
    }
}

// MARK: - SettingsView

struct SettingsView: View {
    let sessionStore: AuthenticatedSessionStore
    @State private var showingRestartAlert = false

    // Environment type selection
    @State private var environmentType: EnvironmentType = switch FirebaseConfiguration.currentMode {
    case .firebase:
        .firebase
    case .emulator:
        switch FirebaseConfiguration.currentEmulatorEnvironment {
        case .localhost:
            .localhost
        case .customIP:
            .customIP
        }
    }

    @State private var selectedFirebaseEnvironment = FirebaseConfiguration.currentFirebaseEnvironment
    @State private var selectedEmulatorEnvironment = FirebaseConfiguration.currentEmulatorEnvironment

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

            Section(header: Text("Debug")) {
                NavigationLink(value: RouterDestination.debugSettings) {
                    HStack {
                        Image(systemName: "gear.badge")
                            .foregroundColor(.orange)
                        Text("Debug Settings")
                        Spacer()
                        Text(currentEnvironmentDescription)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Restart Required", isPresented: $showingRestartAlert) {
            Button("OK") {}
        } message: {
            Text("The environment has been changed to \(currentEnvironmentDescription). Please restart the app for changes to take effect.")
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    private var currentEnvironmentDescription: String {
        switch FirebaseConfiguration.currentMode {
        case .firebase:
            "Firebase \(FirebaseConfiguration.currentFirebaseEnvironment.description)"
        case .emulator:
            FirebaseConfiguration.currentEmulatorEnvironment.description
        }
    }

    private func updateEnvironmentFromSelection() {
        switch environmentType {
        case .firebase:
            FirebaseConfiguration.currentMode = .firebase
        // Keep current Firebase environment
        case .localhost:
            FirebaseConfiguration.currentMode = .emulator
            FirebaseConfiguration.currentEmulatorEnvironment = .localhost
            selectedEmulatorEnvironment = .localhost
        case .customIP:
            FirebaseConfiguration.currentMode = .emulator
            FirebaseConfiguration.currentEmulatorEnvironment = .customIP
            selectedEmulatorEnvironment = .customIP
        }
        showingRestartAlert = true
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
                        teamId: "team123",
                        role: .admin
                    )
                )
            )
        }
    }
}

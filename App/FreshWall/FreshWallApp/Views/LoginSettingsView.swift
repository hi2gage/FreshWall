import SwiftUI

struct LoginSettingsView: View {
    var body: some View {
        List {
            // App Info Section
            Section(header: Text("App Information")) {
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
                Section(header: Text("Development")) {
                    NavigationLink(value: LoginRouterPath.RouterDestination.debugSettings) {
                        HStack {
                            Image(systemName: "gear.badge")
                                .foregroundColor(.orange)
                            Text("Environment Settings")
                            Spacer()
                            Text(currentEnvironmentDescription)
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
            #endif

            // Help Section
            Section(header: Text("Support")) {
                HStack {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.green)
                    Text("Need Help?")
                    Spacer()
                    Text("Contact Support")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            LoginSettingsView()
        }
    }
}

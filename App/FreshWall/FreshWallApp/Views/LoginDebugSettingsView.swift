import SwiftUI

struct LoginDebugSettingsView: View {
    @State private var viewModel = DebugMenuViewModel()

    var body: some View {
        List {
            // Current Environment Display
            Section {}

            Section(header: Text("Environment Settings")) {
                HStack {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .foregroundColor(.green)
                    Text("Current Environment:")
                        .font(.headline)
                    Spacer()
                    Text(currentEnvironmentDescription)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 4)

                VStack {
                    Picker("Mode", selection: $viewModel.environmentMode) {
                        Text("Firebase").tag(EnvironmentMode.firebase)
                        Text("Emulator").tag(EnvironmentMode.emulator)
                    }
                    .pickerStyle(.segmented)

                    if viewModel.environmentMode == .firebase {
                        Picker("Firebase Environment", selection: $viewModel.selectedFirebaseEnvironment) {
                            ForEach(FirebaseEnvironment.allCases, id: \.self) { env in
                                Text(env.description).tag(env)
                            }
                        }
                        .pickerStyle(.segmented)
                    } else {
                        Picker("Emulator Environment", selection: $viewModel.selectedEmulatorEnvironment) {
                            ForEach(EmulatorEnvironment.allCases, id: \.self) { env in
                                Text(env.description).tag(env)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Custom IP Configuration
                    if viewModel.environmentMode == .emulator, viewModel.selectedEmulatorEnvironment == .customIP {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Custom IP Address")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            TextField("192.168.1.100", text: $viewModel.customIP)
                                .textContentType(.URL)
                                .keyboardType(.numbersAndPunctuation)
                                .autocapitalization(.none)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                        .padding(.top, 8)
                    }

                    if hasChanges {
                        Button("Apply Changes") {
                            viewModel.switchEnvironment()
                        }
                        .foregroundColor(.blue)
                    }
                }
            }

            Section(header: Text("Environment Options")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🚀 Firebase Environments")
                        .font(.headline)
                    Text("• Dev: Development Firebase backend")
                    Text("• Beta: Beta testing Firebase backend")
                    Text("• Prod: Production Firebase backend")

                    Text("🏠 Localhost")
                        .font(.headline)
                        .padding(.top)
                    Text("• Test without internet")
                    Text("• Create test accounts freely")
                    Text("• Perfect for simulator")

                    Text("📱 Custom IP")
                        .font(.headline)
                        .padding(.top)
                    Text("• Test on physical device")
                    Text("• Connect to dev machine emulators")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Environment Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Restart Required", isPresented: $viewModel.showingRestartAlert) {
            Button("Restart App") {
                exit(0)
            }
            Button("Later") {}
        } message: {
            Text("The environment has been changed. Would you like to restart the app now for changes to take effect?")
        }
    }

    private var hasChanges: Bool {
        viewModel.environmentMode != FirebaseConfiguration.currentMode ||
            viewModel.selectedFirebaseEnvironment != FirebaseConfiguration.currentFirebaseEnvironment ||
            viewModel.selectedEmulatorEnvironment != FirebaseConfiguration.currentEmulatorEnvironment ||
            viewModel.customIP != FirebaseConfiguration.customIP
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
            LoginDebugSettingsView()
        }
    }
}

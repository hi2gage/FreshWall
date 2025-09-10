import SwiftUI

// MARK: - DebugMenuViewModel

@MainActor
@Observable
class DebugMenuViewModel {
    var environmentMode: EnvironmentMode
    var selectedFirebaseEnvironment: FirebaseEnvironment
    var selectedEmulatorEnvironment: EmulatorEnvironment
    var customIP: String
    var showingRestartAlert = false

    init() {
        self.environmentMode = FirebaseConfiguration.currentMode
        self.selectedFirebaseEnvironment = FirebaseConfiguration.currentFirebaseEnvironment
        self.selectedEmulatorEnvironment = FirebaseConfiguration.currentEmulatorEnvironment
        self.customIP = FirebaseConfiguration.customIP
    }

    func switchEnvironment() {
        // Save custom IP if it changed
        if customIP != FirebaseConfiguration.customIP {
            FirebaseConfiguration.customIP = customIP
        }

        // Switch to the selected environment
        switch environmentMode {
        case .firebase:
            FirebaseConfiguration.switchToFirebase(environment: selectedFirebaseEnvironment)
        case .emulator:
            FirebaseConfiguration.switchToEmulator(environment: selectedEmulatorEnvironment)
        }

        showingRestartAlert = true
    }

    func resetToDefaults() {
        environmentMode = FirebaseConfiguration.currentMode
        selectedFirebaseEnvironment = FirebaseConfiguration.currentFirebaseEnvironment
        selectedEmulatorEnvironment = FirebaseConfiguration.currentEmulatorEnvironment
        customIP = FirebaseConfiguration.customIP
    }
}

// MARK: - DebugMenuView

struct DebugMenuView: View {
    @State private var viewModel = DebugMenuViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
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
            }
            .navigationTitle("Debug Settings")
            .alert("Restart Required", isPresented: $viewModel.showingRestartAlert) {
                Button("Restart App") {
                    exit(0)
                }
                Button("Later") {
                    dismiss()
                }
            } message: {
                Text("The environment has been changed. Would you like to restart the app now for changes to take effect?")
            }
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
        DebugMenuView()
    }
}

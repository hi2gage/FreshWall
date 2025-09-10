import SwiftUI

// MARK: - DebugMenuViewModel

@MainActor
@Observable
class DebugMenuViewModel {
    var selectedEnvironment: FirebaseEnvironment
    var customIP: String
    var showingRestartAlert = false

    init() {
        self.selectedEnvironment = FirebaseConfiguration.currentEnvironment
        self.customIP = FirebaseConfiguration.customIP
    }

    func switchEnvironment() {
        // Save custom IP if it changed
        if customIP != FirebaseConfiguration.customIP {
            FirebaseConfiguration.customIP = customIP
        }

        FirebaseConfiguration.switchEnvironment(to: selectedEnvironment)
        showingRestartAlert = true
    }

    func resetToDefaults() {
        selectedEnvironment = FirebaseConfiguration.currentEnvironment
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
                Section(header: Text("Firebase Environment")) {
                    Picker("Environment", selection: $viewModel.selectedEnvironment) {
                        ForEach(FirebaseEnvironment.allCases, id: \.self) { env in
                            Text(env.description).tag(env)
                        }
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Text("Current:")
                        Spacer()
                        Text(FirebaseConfiguration.currentEnvironment.description)
                            .foregroundColor(.secondary)
                    }
                }

                // Custom IP Configuration
                if viewModel.selectedEnvironment == .customIP {
                    Section(header: Text("Custom IP")) {
                        TextField("IP Address", text: $viewModel.customIP)
                            .textContentType(.URL)
                            .keyboardType(.numbersAndPunctuation)
                            .autocapitalization(.none)
                    }
                }

                // Apply button
                if hasChanges {
                    Section {
                        Button("Apply Changes") {
                            viewModel.switchEnvironment()
                        }
                        .foregroundColor(.blue)
                    }
                }

                Section(header: Text("Environment Details")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Production")
                            .font(.headline)
                        Text("• Uses production Firebase backend")
                        Text("• Real data and authentication")

                        Text("Localhost")
                            .font(.headline)
                            .padding(.top)
                        Text("• Uses Firebase emulators on localhost")
                        Text("• Simulator and local development")

                        Text("Custom IP")
                            .font(.headline)
                            .padding(.top)
                        Text("• Uses Firebase emulators on custom IP")
                        Text("• Device testing with emulators")
                        Text("• Current IP: \(FirebaseConfiguration.customIP)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Debug Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Restart Required", isPresented: $viewModel.showingRestartAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("The environment has been changed to \(viewModel.selectedEnvironment.description). Please restart the app for changes to take effect.")
            }
        }
    }

    private var hasChanges: Bool {
        viewModel.selectedEnvironment != FirebaseConfiguration.currentEnvironment ||
            viewModel.customIP != FirebaseConfiguration.customIP
    }
}

#Preview {
    FreshWallPreview {
        DebugMenuView()
    }
}

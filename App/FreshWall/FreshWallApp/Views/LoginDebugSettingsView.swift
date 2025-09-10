import SwiftUI

struct LoginDebugSettingsView: View {
    @State private var viewModel = DebugMenuViewModel()

    var body: some View {
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

            Section(header: Text("Why Change Environment?")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🚀 Production")
                        .font(.headline)
                    Text("• Test with real backend")
                    Text("• Use existing accounts")

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
            Button("OK") {}
        } message: {
            Text("The environment has been changed to \(viewModel.selectedEnvironment.description). Please restart the app for changes to take effect.")
        }
    }

    private var hasChanges: Bool {
        viewModel.selectedEnvironment != FirebaseConfiguration.currentEnvironment ||
            viewModel.customIP != FirebaseConfiguration.customIP
    }
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            LoginDebugSettingsView()
        }
    }
}

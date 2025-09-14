import SwiftUI

// MARK: - AsyncButton

struct AsyncButton<Label: View>: View {
    private let action: () async throws -> Void
    private let label: () -> Label
    private let role: ButtonRole?

    @State private var isPerforming = false
    @State private var task: Task<Void, Never>?

    /// Creates an async button that displays a custom label.
    init(
        role: ButtonRole? = nil,
        action: @escaping () async throws -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.role = role
        self.action = action
        self.label = label
    }

    var body: some View {
        Button(role: role) {
            guard !isPerforming else { return }

            task = Task {
                isPerforming = true
                defer { isPerforming = false }

                do {
                    try await action()
                } catch {
                    print("AsyncButton error: \(error)")
                }
            }
        } label: {
            HStack {
                if isPerforming {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                }
                label()
            }
        }
        .disabled(isPerforming)
        .onDisappear {
            task?.cancel()
        }
    }
}

// MARK: - Text Label Extensions

extension AsyncButton where Label == Text {
    /// Creates an async button that generates its label from a localized string key.
    init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        action: @escaping () async throws -> Void
    ) {
        self.init(role: role, action: action) {
            Text(titleKey)
        }
    }

    /// Creates an async button that generates its label from a string.
    init(
        _ title: some StringProtocol,
        role: ButtonRole? = nil,
        action: @escaping () async throws -> Void
    ) {
        self.init(role: role, action: action) {
            Text(title)
        }
    }
}

// MARK: - Label Extensions (Text + Image)

extension AsyncButton where Label == SwiftUI.Label<Text, Image> {
    /// Creates an async button that generates its label from a localized string key and system image.
    init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        role: ButtonRole? = nil,
        action: @escaping () async throws -> Void
    ) {
        self.init(role: role, action: action) {
            SwiftUI.Label(titleKey, systemImage: systemImage)
        }
    }

    /// Creates an async button that generates its label from a string and system image.
    init(
        _ title: some StringProtocol,
        systemImage: String,
        role: ButtonRole? = nil,
        action: @escaping () async throws -> Void
    ) {
        self.init(role: role, action: action) {
            SwiftUI.Label(title, systemImage: systemImage)
        }
    }
}

#Preview {
    FreshWallPreview {
        VStack(spacing: 20) {
            // Simple string label
            AsyncButton("Save Incident") {
                try await Task.sleep(for: .seconds(2))
                print("Saved!")
            }

            // With system image
            AsyncButton("Upload", systemImage: "arrow.up.circle") {
                try await Task.sleep(for: .seconds(3))
                print("Uploaded!")
            }

            // Destructive role
            AsyncButton("Delete", role: .destructive) {
                try await Task.sleep(for: .seconds(1))
                print("Deleted!")
            }

            // Custom label
            AsyncButton {
                try await Task.sleep(for: .seconds(1))
                print("Custom action!")
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text("Custom Button")
                }
            }
        }
        .padding()
        .buttonStyle(.bordered)
    }
}

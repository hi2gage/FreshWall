import SwiftUI

struct EditProfileView: View {
    let sessionStore: AuthenticatedSessionStore
    @Environment(RouterPath.self) private var router

    @State private var displayName: String = ""
    @State private var isUpdating = false
    @State private var errorMessage: String?

    private let userService = UserService()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Display Name", text: $displayName)
                        .textFieldStyle(.roundedBorder)
                        .disabled(isUpdating)

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        router.pop()
                    }
                    .disabled(isUpdating)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await updateProfile()
                        }
                    }
                    .disabled(
                        isUpdating ||
                            displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                            displayName.trimmingCharacters(in: .whitespacesAndNewlines) == sessionStore.session.displayName
                    )
                }
            }
            .onAppear {
                displayName = sessionStore.session.displayName
            }
            .overlay {
                if isUpdating {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    ProgressView("Updating...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
        }
    }

    private func updateProfile() async {
        guard !isUpdating else { return }

        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedDisplayName.isEmpty else {
            errorMessage = "Display name cannot be empty"
            return
        }
        guard trimmedDisplayName != sessionStore.session.displayName else {
            router.pop()
            return
        }

        isUpdating = true
        errorMessage = nil

        do {
            try await userService.updateProfile(
                displayName: trimmedDisplayName,
                teamId: sessionStore.session.teamId
            )

            await MainActor.run {
                sessionStore.updateDisplayName(trimmedDisplayName)
                router.pop()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isUpdating = false
            }
        }
    }
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            EditProfileView(
                sessionStore: AuthenticatedSessionStore(
                    sessionStore: SessionStore(),
                    session: UserSession(
                        userId: "user123",
                        displayName: "John Doe",
                        teamId: "team123",
                        role: .admin
                    ),
                    loginManager: LoginManager(
                        sessionStore: SessionStore(),
                        authService: AuthService(),
                        userService: UserService(),
                        sessionService: SessionService()
                    )
                )
            )
        }
        .environment(RouterPath())
    }
}

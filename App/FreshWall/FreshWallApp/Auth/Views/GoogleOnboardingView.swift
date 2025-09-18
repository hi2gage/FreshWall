import SwiftUI

// MARK: - GoogleOnboardingView

/// A view for onboarding Google Sign-In users who aren't yet part of any team.
struct GoogleOnboardingView: View {
    let loginManager: LoginManaging
    @Environment(\.dismiss) private var dismiss

    @State private var displayName: String = ""
    @State private var teamName: String = ""
    @State private var teamCode: String = ""
    @State private var errorMessage: String?
    @State private var isCreatingTeam = true

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Complete Your Setup")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your Google account is connected! Now let's set up your team.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                TextField("Your Display Name", text: $displayName)
                    .textContentType(.name)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                Picker("Choose Option", selection: $isCreatingTeam) {
                    Text("Create New Team").tag(true)
                    Text("Join Existing Team").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.vertical)

                if isCreatingTeam {
                    TextField("Team Name", text: $teamName)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                } else {
                    TextField("Team Code", text: $teamCode)
                        .textContentType(.oneTimeCode)
                        .autocapitalization(.allCharacters)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }

                if let message = errorMessage {
                    Text(message)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Button(isCreatingTeam ? "Create Team" : "Join Team") {
                    Task {
                        await handleTeamAction()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    (isCreatingTeam && teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ||
                    (!isCreatingTeam && teamCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))

                Spacer()
            }
            .padding()
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func handleTeamAction() async {
        do {
            let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

            if isCreatingTeam {
                let trimmedTeamName = teamName.trimmingCharacters(in: .whitespacesAndNewlines)
                try await loginManager.createTeamForGoogleUser(
                    displayName: trimmedDisplayName,
                    teamName: trimmedTeamName
                )
            } else {
                let trimmedTeamCode = teamCode.trimmingCharacters(in: .whitespacesAndNewlines)
                try await loginManager.joinTeamForGoogleUser(
                    displayName: trimmedDisplayName,
                    teamCode: trimmedTeamCode
                )
            }
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    FreshWallPreview {
        GoogleOnboardingView(loginManager: PreviewLoginManager())
    }
}

// MARK: - PreviewLoginManager

struct PreviewLoginManager: LoginManaging {
    func signInWithGoogle() async throws {}
    func signIn(email _: String, password _: String) async throws {}
    func signUp(email _: String, password _: String, displayName _: String, teamName _: String) async throws {}
    func signUp(email _: String, password _: String, displayName _: String, teamCode _: String) async throws {}
    func createTeamForGoogleUser(displayName _: String, teamName _: String) async throws {}
    func joinTeamForGoogleUser(displayName _: String, teamCode _: String) async throws {}
}

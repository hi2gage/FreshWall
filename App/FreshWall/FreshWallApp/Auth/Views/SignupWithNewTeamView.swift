import SwiftUI

// MARK: - SignupWithNewTeamView

/// A view that allows new users to create an account and team.
struct SignupWithNewTeamView: View {
    let loginManager: LoginManaging
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    @State private var teamName: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign Up")
                .font(.largeTitle)
            TextField("Full Name", text: $displayName)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            TextField("Team Name", text: $teamName)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            if let message = errorMessage {
                Text(message)
                    .foregroundColor(.red)
            }
            Button("Create Account") {
                Task {
                    do {
                        try await loginManager.signUp(
                            email: email,
                            password: password,
                            displayName: displayName,
                            teamName: teamName
                        )
                        dismiss()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - PreviewLoginManager

struct PreviewLoginManager: LoginManaging {
    func createTeamForGoogleUser(displayName _: String, teamName _: String) async throws {}

    func joinTeamForGoogleUser(displayName _: String, teamCode _: String) async throws {}

    func signInWithGoogle() async throws {}
    func signIn(email _: String, password _: String) async throws {}
    func signUp(email _: String, password _: String, displayName _: String, teamName _: String) async throws {}
    func signUp(email _: String, password _: String, displayName _: String, teamCode _: String) async throws {}
}

#Preview {
    FreshWallPreview {
        SignupWithNewTeamView(loginManager: PreviewLoginManager())
    }
}

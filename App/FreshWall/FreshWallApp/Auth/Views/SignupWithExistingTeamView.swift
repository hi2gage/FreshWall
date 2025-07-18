import SwiftUI

/// A view that allows new users to create an account and team.
struct SignupWithExistingTeamView: View {
    let loginManager: LoginManaging
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    @State private var teamCode: String = ""
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
            TextField("Team Code (optional)", text: $teamCode)
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
                            teamCode: teamCode
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

#Preview {
    FreshWallPreview {
        SignupWithExistingTeamView(loginManager: PreviewLoginManager())
    }
}

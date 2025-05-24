import SwiftUI

/// A view that allows new users to create an account and team.
struct SignupView: View {
    @EnvironmentObject private var authService: AuthService
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
                        try await authService.signUp(
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

#Preview {
    SignupView()
        .environmentObject(AuthService())
}

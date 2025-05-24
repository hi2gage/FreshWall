import SwiftUI

/// A view that allows existing users to log in with email and password.
struct LoginView: View {
    @EnvironmentObject private var authService: AuthService
    @Environment(RouterPath.self) private var routerPath
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Log In")
                .font(.largeTitle)
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
            if let message = errorMessage {
                Text(message)
                    .foregroundColor(.red)
            }
            Button("Log In") {
                Task {
                    do {
                        try await authService.signIn(email: email, password: password)
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
            Button("Sign Up") {
                routerPath.push(.signup)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
}

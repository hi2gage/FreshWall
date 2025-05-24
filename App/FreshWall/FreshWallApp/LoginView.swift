import SwiftUI

/// A view that allows existing users to log in with email and password.
struct LoginView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var showSignup: Bool = false

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
                authService.signIn(email: email, password: password) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    }
                }
            }
            Button("Sign Up") {
                showSignup = true
            }
            NavigationLink(
                destination: SignupView(),
                isActive: $showSignup,
                label: { EmptyView() }
            )
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
}

@preconcurrency import FirebaseAuth
import FirebaseFirestore
import SwiftUI

/// Authentication flow: login, signup, then callback with UserSession.
struct AuthFlowView: View {
    let loginManager: LoginManager

    @State private var routerPath: LoginRouterPath

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    init(
        loginManager: LoginManager,
        routerPath: LoginRouterPath = LoginRouterPath()
    ) {
        self.loginManager = loginManager
        _routerPath = State(wrappedValue: routerPath)
    }

    var body: some View {
        NavigationStack(path: $routerPath.path) {
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
                            try await loginManager.signIn(email: email, password: password)
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                Button("Sign Up") {
                    routerPath.push(.signup)
                }
                Button("Sign Up with Team") {
                    routerPath.push(.signupWithTeam)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Authenticate")
            .withAppLoginRouter(loginManager: loginManager)
        }
        .environment(routerPath)
    }
}

// #Preview {
//    FreshWallPreview {
//        AuthFlowView(sessionStore: SessionStore())
//    }
// }

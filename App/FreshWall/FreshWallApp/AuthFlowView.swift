import SwiftUI
import FirebaseAuth

/// Authentication flow: login, signup, then callback with UserSession.
struct AuthFlowView: View {
    /// Called when authentication completes with valid userId and teamId.
    @State private var sessionStore: SessionStore

    @State private var routerPath = RouterPath()
    @State private var authService = AuthService()
    @State private var userService = UserService()

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    init(
        sessionStore: SessionStore,
        routerPath: RouterPath = RouterPath(),
        authService: AuthService = AuthService(),
        userService: UserService = UserService(),
    ) {
        self.sessionStore = sessionStore
        self.routerPath = routerPath
        self.authService = authService
        self.userService = userService
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
                            try await authService.signIn(email: email, password: password)
                            guard let user = Auth.auth().currentUser else { return }
                            await userService.fetchUserRecord(for: user)
                            if let teamId = userService.teamId {
                                sessionStore.startSession(
                                    UserSession(userId: user.uid, teamId: teamId)
                                )
                            }
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
            .navigationDestination(for: RouterDestination.self) { dest in
                switch dest {
                case .signup:
                    SignupWithExistingTeamView(userService: userService)
                case .signupWithTeam:
                    SignupWithNewTeamView(userService: userService)
                default:
                    EmptyView()
                }
            }
        }
        .environment(routerPath)
    }
}

#Preview {
    FreshWallPreview {
        AuthFlowView(sessionStore: SessionStore())
    }
}

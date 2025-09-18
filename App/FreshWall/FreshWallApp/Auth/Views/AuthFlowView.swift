@preconcurrency import FirebaseAuth
import FirebaseFirestore
import GoogleSignInSwift
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
            VStack(spacing: 24) {
                // Header
                Text("Log In")
                    .font(.largeTitle)
                    .fontWeight(.medium)

                // Email/Password Section
                VStack(spacing: 16) {
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
                            .font(.caption)
                            .padding(.top, -8)
                    }

                    Button("Log In") {
                        Task {
                            do {
                                try await loginManager.signIn(email: email, password: password)
                            } catch {
                                // Check for account not found errors
                                if error.localizedDescription.contains("user-not-found") ||
                                    error.localizedDescription.contains("invalid-email") ||
                                    error.localizedDescription.contains("No existing account found") {
                                    errorMessage = "Please create account first"
                                } else {
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

                // Divider with "OR"
                HStack {
                    VStack { Divider() }
                    Text("OR")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    VStack { Divider() }
                }
                .padding(.vertical, 8)

                // Other Sign In Options
                VStack(spacing: 16) {
                    Text("Other sign in options")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    GoogleSignInButton(
                        scheme: .dark,
                        style: .icon,
                        state: .normal
                    ) {
                        Task {
                            do {
                                try await loginManager.signInWithGoogle()
                            } catch let googleError as GoogleSignInOnboardingError {
                                switch googleError {
                                case .userNotInTeam:
                                    routerPath.push(.googleOnboarding)
                                }
                            } catch {
                                // Check for account not found errors from Google Sign-In
                                if error is AuthError ||
                                    error.localizedDescription.contains("No existing account found") {
                                    errorMessage = "Please create account first"
                                } else {
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                    }
                    .frame(height: 44)
                }

                Spacer()

                // Netflix-style bottom section
                VStack(spacing: 12) {
                    Text("Create a FreshWall account and more.")
                        .foregroundColor(.primary)
                        .font(.subheadline)

                    Button("Go to freshwall.app/more") {
                        if let url = URL(string: "https://freshwall.app/more") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundColor(.blue)
                    .font(.subheadline)
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
            }
            .padding()
            .navigationTitle("Authenticate")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        routerPath.push(.loginSettings)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .withAppLoginRouter(loginManager: loginManager)
        }
        .environment(routerPath)
        .onShake {
            routerPath.push(.debugSettings)
        }
    }
}

#Preview {
    FreshWallPreview {
        AuthFlowView(loginManager: LoginManager(
            sessionStore: SessionStore(),
            authService: AuthService(),
            userService: UserService(),
            sessionService: SessionService()
        ))
    }
}

@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseFunctions
import Foundation
import GoogleSignIn

// MARK: - AuthService

/// Service that manages Firebase authentication and Firestore user records.
struct AuthService {
    private let auth = Auth.auth()

    /// Starts listening for Firebase authentication state changes.
    init() {}

    /// Signs in an existing user with email and password.
    ///
    /// - Parameters:
    ///   - email: Email address used for sign-in.
    ///   - password: Password for authentication.
    @discardableResult
    func signIn(
        email: String,
        password: String
    ) async throws -> FirebaseAuth.User {
        try await auth.signIn(withEmail: email, password: password).user
    }

    /// Signs out the current user.
    ///
    /// - Returns: An optional error if sign-out fails.
    func signOut() throws {
        try auth.signOut()
    }

    func getCurrentUser() -> FirebaseAuth.User? {
        auth.currentUser
    }

    /// Signs in with Google using GoogleSignIn SDK and Firebase Auth
    @discardableResult
    func signInWithGoogle() async throws -> FirebaseAuth.User {
        // Get the top view controller for presenting Google Sign-In
        guard let presentingViewController = await MainActor.run(body: {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first(where: \.isKeyWindow)?
                .rootViewController
        }) else {
            throw AuthError.noPresentingViewController
        }

        // Configure Google Sign-In
        guard let clientID = auth.app?.options.clientID else {
            throw AuthError.noClientID
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        // Start Google Sign-In flow
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        let user = result.user

        guard let idToken = user.idToken?.tokenString else {
            throw AuthError.noIDToken
        }

        let accessToken = user.accessToken.tokenString

        // Create Firebase credential from Google tokens
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

        // Sign in to Firebase with Google credential
        return try await auth.signIn(with: credential).user
    }
}

// MARK: - AuthError

/// Errors related to Google Sign-In authentication
enum AuthError: LocalizedError {
    case noPresentingViewController
    case noClientID
    case noIDToken

    var errorDescription: String? {
        switch self {
        case .noPresentingViewController:
            "Could not find a presenting view controller"
        case .noClientID:
            "No client ID found in Firebase configuration"
        case .noIDToken:
            "No ID token received from Google"
        }
    }
}

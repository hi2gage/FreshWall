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

    /// Signs out the current user from both Firebase and Google.
    ///
    /// - Returns: An optional error if sign-out fails.
    func signOut() throws {
        // Sign out from Google first (this clears the Google session completely)
        GIDSignIn.sharedInstance.signOut()

        // Then sign out from Firebase
        try auth.signOut()
    }

    func getCurrentUser() -> FirebaseAuth.User? {
        auth.currentUser
    }

    /// Signs in with Google using GoogleSignInSwift and Firebase Auth
    @discardableResult
    @MainActor
    func signInWithGoogle() async throws -> FirebaseAuth.User {
        // Configure Google Sign-In
        guard let clientID = auth.app?.options.clientID else {
            throw AuthError.noClientID
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        // Get the top view controller for presenting Google Sign-In
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let presentingViewController = window.rootViewController else {
            throw AuthError.noPresentingViewController
        }

        // Use continuation to bridge completion handler to async/await
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let result else {
                    continuation.resume(throwing: AuthError.noIDToken)
                    return
                }

                let user = result.user

                guard let idToken = user.idToken?.tokenString else {
                    continuation.resume(throwing: AuthError.noIDToken)
                    return
                }

                let accessToken = user.accessToken.tokenString

                // Create Firebase credential from Google tokens
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

                // Sign in to Firebase with Google credential
                Task {
                    do {
                        let firebaseUser = try await self.auth.signIn(with: credential).user

                        // Check if this is a new user (just created by Firebase)
                        if firebaseUser.metadata.creationDate?.timeIntervalSinceNow ?? 0 > -10 {
                            // This is a new user - sign them out immediately and delete the account
                            try await firebaseUser.delete()
                            continuation.resume(throwing: AuthError.accountNotFound)
                            return
                        }

                        continuation.resume(returning: firebaseUser)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}

// MARK: - AuthError

/// Errors related to Google Sign-In authentication
enum AuthError: LocalizedError {
    case noPresentingViewController
    case noClientID
    case noIDToken
    case accountNotFound

    var errorDescription: String? {
        switch self {
        case .noPresentingViewController:
            "Could not find a presenting view controller"
        case .noClientID:
            "No client ID found in Firebase configuration"
        case .noIDToken:
            "No ID token received from Google"
        case .accountNotFound:
            "No existing account found"
        }
    }
}

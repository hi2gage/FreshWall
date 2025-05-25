import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import Foundation
import Observation

/// Service that manages Firebase authentication and Firestore user records.
@Observable
final class AuthService {
    /// The current Firebase `User` session.
    var userSession: FirebaseAuth.User?

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let auth = Auth.auth()

    /// Indicates whether a user is currently authenticated.
    var isAuthenticated: Bool { userSession != nil }

    /// Starts listening for Firebase authentication state changes.
    init() {
        #if DEBUG
            let settings = Firestore.firestore().settings
            settings.host = "localhost:8080"
            settings.isSSLEnabled = false
            settings.isPersistenceEnabled = false
            Firestore.firestore().settings = settings

            Functions.functions().useEmulator(withHost: "localhost", port: 5001)

            Auth.auth().useEmulator(withHost: "localhost", port: 9099)
        #endif
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
            self?.userSession = user
        }
    }

    deinit {
        if let handle = authStateHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }

    /// Signs in an existing user with email and password.
    ///
    /// - Parameters:
    ///   - email: Email address used for sign-in.
    ///   - password: Password for authentication.
    func signIn(
        email: String,
        password: String
    ) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }

    /// Signs out the current user.
    ///
    /// - Returns: An optional error if sign-out fails.
    @discardableResult
    func signOut() -> Error? {
        do {
            try auth.signOut()
            return nil
        } catch {
            return error
        }
    }
}

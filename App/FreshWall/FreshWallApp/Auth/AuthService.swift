@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseFunctions
import Foundation

/// Service that manages Firebase authentication and Firestore user records.
struct AuthService {
    private let auth = Auth.auth()

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
    }

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
        return auth.currentUser
    }
}

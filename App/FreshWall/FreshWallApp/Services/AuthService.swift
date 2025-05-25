@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseFunctions
import Foundation
import Observation

/// Service that manages Firebase authentication and Firestore user records.
@Observable
@MainActor
final class AuthService {
    /// The current Firebase `User` session.
    var userSession: AuthState?

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let auth = Auth.auth()

    /// Indicates whether a user is currently authenticated.
    var isAuthenticated: Bool { userSession != nil }

    @ObservationIgnored
    private nonisolated(unsafe) var authListenerTask: Task<Void, Never>?

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

        authListenerTask = Task {
            for await user in authStateStream() {
                self.userSession = user
            }
        }
    }

    deinit {
        authListenerTask?.cancel()
    }

    struct AuthState: Sendable {
        var uid: String
        var email: String?
    }

    func authStateStream() -> AsyncStream<AuthState?> {
        AsyncStream { continuation in
            let handle = Auth.auth().addStateDidChangeListener { _, user in
                if let user {
                    continuation.yield(AuthState(uid: user.uid, email: user.email))
                } else {
                    continuation.yield(nil)
                }
            }

            continuation.onTermination = { _ in
                Auth.auth().removeStateDidChangeListener(handle)
            }
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

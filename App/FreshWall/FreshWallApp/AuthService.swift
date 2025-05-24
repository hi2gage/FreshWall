import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

/// Service that manages Firebase authentication and Firestore user records.
final class AuthService: ObservableObject {
    /// The current Firebase `User` session.
    @Published var userSession: FirebaseAuth.User?
    /// The Firestore `User` record associated with the current session.
    @Published var userRecord: User?
    /// The team identifier to which the current user belongs.
    @Published var teamId: String?

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    /// Indicates whether a user is currently authenticated.
    var isAuthenticated: Bool { userSession != nil }

    /// Starts listening for Firebase authentication state changes.
    init() {
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
            self?.userSession = user
            if let user = user {
                self?.fetchUserRecord(user: user)
            } else {
                self?.userRecord = nil
                self?.teamId = nil
            }
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
    ///   - completion: Closure called with an optional error after sign-in attempt.
    func signIn(
        email: String,
        password: String,
        completion: @escaping (Error?) -> Void
    ) {
        auth.signIn(withEmail: email, password: password) { _, error in
            completion(error)
        }
    }

    /// Creates a new user account, team, and Firestore user record.
    ///
    /// - Parameters:
    ///   - email: Email address for new account.
    ///   - password: Password for authentication.
    ///   - displayName: Name to display for the user.
    ///   - teamName: Name of the team to create.
    ///   - completion: Closure called with an optional error after signup process.
    func signUp(
        email: String,
        password: String,
        displayName: String,
        teamName: String,
        completion: @escaping (Error?) -> Void
    ) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(error)
                return
            }
            guard let self = self, let user = result?.user else {
                let err = NSError(
                    domain: "AuthService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user after sign-up"]
                )
                completion(err)
                return
            }
            let teamRef = self.db.collection("teams").document()
            let teamData: [String: Any] = [
                "name": teamName,
                "createdAt": Timestamp()
            ]
            teamRef.setData(teamData) { error in
                if let error = error {
                    completion(error)
                    return
                }
                let userRef = teamRef.collection("users").document(user.uid)
                var recordData: [String: Any] = [
                    "displayName": displayName,
                    "email": email,
                    "role": UserRole.lead.rawValue,
                    "isDeleted": false
                ]
                userRef.setData(recordData) { error in
                    completion(error)
                }
            }
        }
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

    /// Retrieves the Firestore user record and team ID for the given Firebase user.
    ///
    /// - Parameter user: The authenticated Firebase user.
    private func fetchUserRecord(user: FirebaseAuth.User) {
        // If you persist teamId in user defaults, settings, or elsewhere, read it here.
        // But for now, let's fetch it using a workaround based on assumption:
        // Each user is only in ONE team, and that team was just created on sign-up

        db.collection("teams").getDocuments { [weak self] snapshot, error in
            guard let self = self,
                  let documents = snapshot?.documents else {
                return
            }

            for teamDoc in documents {
                let userRef = teamDoc.reference.collection("users").document(user.uid)
                userRef.getDocument { userDocSnapshot, _ in
                    guard let userDoc = userDocSnapshot, userDoc.exists,
                          let data = userDoc.data(),
                          let displayName = data["displayName"] as? String,
                          let email = data["email"] as? String,
                          let roleRaw = data["role"] as? String,
                          let role = UserRole(rawValue: roleRaw),
                          let isDeleted = data["isDeleted"] as? Bool
                    else {
                        return
                    }

                    let deletedAt = data["deletedAt"] as? Timestamp
                    self.userRecord = User(
                        id: user.uid,
                        displayName: displayName,
                        email: email,
                        role: role,
                        isDeleted: isDeleted,
                        deletedAt: deletedAt
                    )
                    self.teamId = teamDoc.documentID
                }
            }
        }
    }
}

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

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
    func signIn(
        email: String,
        password: String
    ) async throws {
        try await auth.signIn(withEmail: email, password: password)

    }

    /// Creates a new user account, team, and Firestore user record via Cloud Function.
    ///
    /// - Parameters:
    ///   - email: Email address for new account.
    ///   - password: Password for authentication.
    ///   - displayName: Name to display for the user.
    ///   - teamName: Name of the team to create.
    func signUp(
        email: String,
        password: String,
        displayName: String,
        teamName: String
    ) async throws {
        let authResult = try await auth.createUser(withEmail: email, password: password)
        let user = authResult.user

        let result = try await Functions.functions()
            .httpsCallable("createTeamCreateUser")
            .call([
                "email": email,
                "teamName": teamName,
                "displayName": displayName
            ])

        guard
            let data = result.data as? [String: Any],
            let teamId = data["teamId"] as? String,
            let teamCode = data["teamCode"] as? String
        else {
            throw NSError(
                domain: "AuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response from createTeamCreateUser function"]
            )
        }

        UserDefaults.standard.set(teamId, forKey: "teamId")
        UserDefaults.standard.set(teamCode, forKey: "teamCode")
        self.teamId = teamId

        self.userRecord = User(
            id: nil,
            displayName: displayName,
            email: email,
            role: .lead,
            isDeleted: false,
            deletedAt: nil
        )

        self.userSession = user
    }

    /// Creates a new user account, team, and Firestore user record. Must just an existing team
    ///
    /// - Parameters:
    ///   - email: Email address for new account.
    ///   - password: Password for authentication.
    ///   - displayName: Name to display for the user.
    ///   - teamName: Name of the team to create.
    func signUp(
        email: String,
        password: String,
        displayName: String,
        teamCode: String
    ) async throws {
        // Step 1: Create Firebase Auth user
        let authResult = try await auth.createUser(withEmail: email, password: password)
        let user = authResult.user

        // Step 2: Call the Firebase Cloud Function to join the team
        let result = try await Functions.functions()
            .httpsCallable("joinTeamCreateUser")
            .call([
                "email": email,
                "teamCode": teamCode,
                "displayName": displayName
            ])

        // Step 3: Extract teamId from function response
        guard
            let data = result.data as? [String: Any],
            let teamId = data["teamId"] as? String
        else {
            throw NSError(
                domain: "AuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response from joinTeamCreateUser function"]
            )
        }

        // Step 4: Update local app state
        UserDefaults.standard.set(teamId, forKey: "teamId")
        self.teamId = teamId

        self.userRecord = User(
            id: nil,
            displayName: displayName,
            email: email,
            role: .member,
            isDeleted: false,
            deletedAt: nil
        )

        self.userSession = user
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
    func fetchUserRecord(user: FirebaseAuth.User) {
        db.collection("teams").getDocuments { [weak self] snapshot, error in
            guard let self = self,
                  let documents = snapshot?.documents else {
                print("Failed to fetch teams")
                return
            }

            for teamDoc in documents {
                let userRef = teamDoc.reference.collection("users").document(user.uid)

                userRef.getDocument { userDocSnapshot, error in
                    // ✅ If user exists in this team, load them
                    if let userDoc = userDocSnapshot, userDoc.exists,
                       let data = userDoc.data(),
                       let displayName = data["displayName"] as? String,
                       let email = data["email"] as? String,
                       let roleRaw = data["role"] as? String,
                       let role = UserRole(rawValue: roleRaw),
                       let isDeleted = data["isDeleted"] as? Bool {

                        let deletedAt = data["deletedAt"] as? Timestamp
                        self.userRecord = User(
                            displayName: displayName,
                            email: email,
                            role: role,
                            isDeleted: isDeleted,
                            deletedAt: deletedAt
                        )
                        self.teamId = teamDoc.documentID
                        UserDefaults.standard.set(teamDoc.documentID, forKey: "teamId")
                    }
                }
            }
        }
    }
}

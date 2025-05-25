import Foundation
import Observation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

/// Service handling user creation, team creation/joining, and user record retrieval.
@Observable
final class UserService {
    /// The Firestore `User` record associated with the current session.
    var userRecord: User?
    /// The team identifier to which the current user belongs.
    var teamId: String?
    /// The code used to create or join the team (if applicable).
    var teamCode: String?

    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let functions = Functions.functions()
    private var authStateHandle: AuthStateDidChangeListenerHandle?

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
            if let user = user {
                Task { await self?.fetchUserRecord(for: user) }
            } else {
                self?.userRecord = nil
                self?.teamId = nil
                self?.teamCode = nil
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }

    /// Creates a new Firebase Auth user, a new team, and the corresponding Firestore user record.
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
        _ = authResult.user

        let result = try await functions
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
                domain: "UserService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response from createTeamCreateUser function"]
            )
        }

        self.teamId = teamId
        self.teamCode = teamCode
        self.userRecord = User(
            id: nil,
            displayName: displayName,
            email: email,
            role: .lead,
            isDeleted: false,
            deletedAt: nil
        )
    }

    /// Creates a new Firebase Auth user and joins an existing team.
    ///
    /// - Parameters:
    ///   - email: Email address for new account.
    ///   - password: Password for authentication.
    ///   - displayName: Name to display for the user.
    ///   - teamCode: Code of the team to join.
    func signUp(
        email: String,
        password: String,
        displayName: String,
        teamCode: String
    ) async throws {
        let authResult = try await auth.createUser(withEmail: email, password: password)
        _ = authResult.user

        let result = try await functions
            .httpsCallable("joinTeamCreateUser")
            .call([
                "email": email,
                "teamCode": teamCode,
                "displayName": displayName
            ])

        guard
            let data = result.data as? [String: Any],
            let teamId = data["teamId"] as? String
        else {
            throw NSError(
                domain: "UserService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response from joinTeamCreateUser function"]
            )
        }

        self.teamId = teamId
        self.teamCode = teamCode
        self.userRecord = User(
            id: nil,
            displayName: displayName,
            email: email,
            role: .member,
            isDeleted: false,
            deletedAt: nil
        )
    }

    /// Fetches the Firestore user record and team ID for the given Firebase user.
    ///
    /// - Parameter user: The authenticated Firebase user.
    func fetchUserRecord(for user: FirebaseAuth.User) async {
        do {
            let teamsSnapshot = try await db.collection("teams").getDocuments()
            for teamDoc in teamsSnapshot.documents {
                let userDoc = try await teamDoc.reference
                    .collection("users")
                    .document(user.uid)
                    .getDocument()
                if userDoc.exists, let data = userDoc.data() {
                    guard
                        let displayName = data["displayName"] as? String,
                        let email = data["email"] as? String,
                        let roleRaw = data["role"] as? String,
                        let role = UserRole(rawValue: roleRaw),
                        let isDeleted = data["isDeleted"] as? Bool
                    else { continue }
                    let deletedAt = data["deletedAt"] as? Timestamp
                    self.userRecord = User(
                        id: nil,
                        displayName: displayName,
                        email: email,
                        role: role,
                        isDeleted: isDeleted,
                        deletedAt: deletedAt
                    )
                    self.teamId = teamDoc.documentID
                    break
                }
            }
        } catch {
            print("Failed to fetch user record: \(error)")
        }
    }
}
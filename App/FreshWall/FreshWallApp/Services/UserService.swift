@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseFunctions
import Foundation

/// Service handling user creation, team creation/joining, and user record retrieval.
struct UserService {
    private let auth = Auth.auth()
    private let functions = Functions.functions()

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

    /// Creates a new Firebase Auth user, a new team, and the corresponding Firestore user record.
    ///
    /// - Parameters:
    ///   - email: Email address for new account.
    ///   - password: Password for authentication.
    ///   - displayName: Name to display for the user.
    ///   - teamName: Name of the team to create.
    @discardableResult
    func signUp(
        email: String,
        password: String,
        displayName: String,
        teamName: String
    ) async throws -> UserDTO {
        let authResult = try await auth.createUser(withEmail: email, password: password)
        _ = authResult.user

        let result = try await functions
            .httpsCallable("createTeamCreateUser")
            .call([
                "email": email,
                "teamName": teamName,
                "displayName": displayName,
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

        return UserDTO(
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
    @discardableResult
    func signUp(
        email: String,
        password: String,
        displayName: String,
        teamCode: String
    ) async throws -> UserDTO {
        let authResult = try await auth.createUser(withEmail: email, password: password)
        _ = authResult.user

        let result = try await functions
            .httpsCallable("joinTeamCreateUser")
            .call([
                "email": email,
                "teamCode": teamCode,
                "displayName": displayName,
            ])

        guard
            let data = result.data as? [String: Any]
        else {
            throw NSError(
                domain: "UserService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response from joinTeamCreateUser function"]
            )
        }

        return UserDTO(
            id: nil,
            displayName: displayName,
            email: email,
            role: .member,
            isDeleted: false,
            deletedAt: nil
        )
    }
}

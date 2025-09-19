@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseFunctions
import Foundation

/// Service handling user creation, team creation/joining, and user record retrieval.
struct UserService {
    private let auth = Auth.auth()
    private let functions = Functions.functions()

    init() {}

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
        let user = authResult.user

        do {
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
                let teamCode = data["teamCode"] as? String else {
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
                role: .admin,
                isDeleted: false,
                deletedAt: nil
            )
        } catch {
            // If team creation fails, clean up the created user
            do {
                try await user.delete()
            } catch {
                // Log the cleanup failure but still throw the original error
                print("Warning: Failed to delete user after team creation failure: \(error)")
            }

            // Re-throw the original error
            throw error
        }
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
        let user = authResult.user

        do {
            let result = try await functions
                .httpsCallable("joinTeamCreateUser")
                .call([
                    "email": email,
                    "teamCode": teamCode,
                    "displayName": displayName,
                ])

            guard
                let data = result.data as? [String: Any] else {
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
                role: .fieldWorker,
                isDeleted: false,
                deletedAt: nil
            )
        } catch {
            // If team joining fails, clean up the created user
            do {
                try await user.delete()
            } catch {
                // Log the cleanup failure but still throw the original error
                print("Warning: Failed to delete user after team joining failure: \(error)")
            }

            // Re-throw the original error
            throw error
        }
    }

    /// Creates a team and user record for an already authenticated user (e.g., Google Sign-In).
    ///
    /// - Parameters:
    ///   - displayName: Name to display for the user.
    ///   - teamName: Name of the team to create.
    @discardableResult
    func createTeamForAuthenticatedUser(
        displayName: String,
        teamName: String
    ) async throws -> UserDTO {
        guard let user = auth.currentUser else {
            throw NSError(
                domain: "UserService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No authenticated user found"]
            )
        }

        let result = try await functions
            .httpsCallable("createTeamCreateUser")
            .call([
                "email": user.email ?? "",
                "teamName": teamName,
                "displayName": displayName,
            ])

        guard
            let data = result.data as? [String: Any],
            let teamId = data["teamId"] as? String,
            let teamCode = data["teamCode"] as? String else {
            throw NSError(
                domain: "UserService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response from createTeamCreateUser function"]
            )
        }

        return UserDTO(
            id: nil,
            displayName: displayName,
            email: user.email ?? "",
            role: .admin,
            isDeleted: false,
            deletedAt: nil
        )
    }

    /// Joins an existing team for an already authenticated user (e.g., Google Sign-In).
    ///
    /// - Parameters:
    ///   - displayName: Name to display for the user.
    ///   - teamCode: Code of the team to join.
    @discardableResult
    func joinTeamForAuthenticatedUser(
        displayName: String,
        teamCode: String
    ) async throws -> UserDTO {
        guard let user = auth.currentUser else {
            throw NSError(
                domain: "UserService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No authenticated user found"]
            )
        }

        let result = try await functions
            .httpsCallable("joinTeamCreateUser")
            .call([
                "email": user.email ?? "",
                "teamCode": teamCode,
                "displayName": displayName,
            ])

        guard
            let data = result.data as? [String: Any] else {
            throw NSError(
                domain: "UserService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response from joinTeamCreateUser function"]
            )
        }

        return UserDTO(
            id: nil,
            displayName: displayName,
            email: user.email ?? "",
            role: .fieldWorker,
            isDeleted: false,
            deletedAt: nil
        )
    }

    /// Updates the current user's profile information.
    ///
    /// - Parameters:
    ///   - displayName: New display name for the user.
    ///   - teamId: The team ID where the user's document exists.
    func updateProfile(displayName: String, teamId: String) async throws {
        guard let currentUser = auth.currentUser else {
            throw NSError(
                domain: "UserService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No authenticated user found"]
            )
        }

        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedDisplayName.isEmpty else {
            throw NSError(
                domain: "UserService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Display name cannot be empty"]
            )
        }
        guard trimmedDisplayName.count <= 100 else {
            throw NSError(
                domain: "UserService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Display name cannot exceed 100 characters"]
            )
        }

        let userDocRef = Firestore.firestore()
            .collection("teams")
            .document(teamId)
            .collection("users")
            .document(currentUser.uid)

        try await userDocRef.updateData([
            "displayName": trimmedDisplayName,
            "lastModified": FieldValue.serverTimestamp(),
            "lastModifiedBy": currentUser.uid,
        ])
    }
}

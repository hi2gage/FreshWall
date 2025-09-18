import Foundation

// MARK: - GoogleSignInOnboardingError

enum GoogleSignInOnboardingError: LocalizedError {
    case userNotInTeam

    var errorDescription: String? {
        switch self {
        case .userNotInTeam:
            "Please create a team or join an existing team to continue"
        }
    }
}

// MARK: - LoginManaging

protocol LoginManaging: Sendable {
    func signIn(
        email: String,
        password: String
    ) async throws

    func signInWithGoogle() async throws

    func signUp(
        email: String,
        password: String,
        displayName: String,
        teamName: String
    ) async throws

    func signUp(
        email: String,
        password: String,
        displayName: String,
        teamCode: String
    ) async throws

    func createTeamForGoogleUser(
        displayName: String,
        teamName: String
    ) async throws

    func joinTeamForGoogleUser(
        displayName: String,
        teamCode: String
    ) async throws
}

// MARK: - LoginManager

struct LoginManager: LoginManaging {
    /// Called when authentication completes with valid userId and teamId.
    private let sessionStore: SessionStore
    private let authService: AuthService
    private let userService: UserService
    private let sessionService: SessionService

    init(
        sessionStore: SessionStore,
        authService: AuthService,
        userService: UserService,
        sessionService: SessionService
    ) {
        self.sessionStore = sessionStore
        self.authService = authService
        self.userService = userService
        self.sessionService = sessionService
    }

    func restoreSessionIfAvailable() async {
        guard let user = authService.getCurrentUser() else {
            return // No cached session
        }

        do {
            let session = try await sessionService.fetchUserRecord(for: user)
            await sessionStore.startSession(session)
        } catch {
            print("🔒 Failed to restore session:", error)
            // Optionally, sign out if invalid
            try? authService.signOut()
        }
    }

    func signIn(
        email: String,
        password: String
    ) async throws {
        let firestoreUser = try await authService.signIn(email: email, password: password)
        let session = try await sessionService.fetchUserRecord(for: firestoreUser)
        await sessionStore.startSession(session)
    }

    func signInWithGoogle() async throws {
        let firestoreUser = try await authService.signInWithGoogle()
        do {
            let session = try await sessionService.fetchUserRecord(for: firestoreUser)
            await sessionStore.startSession(session)
        } catch {
            // User exists in Firebase Auth but not in any team - they need to be onboarded
            if let nsError = error as NSError?, nsError.code == 404 {
                throw GoogleSignInOnboardingError.userNotInTeam
            }
            throw error
        }
    }

    func signUp(
        email: String,
        password: String,
        displayName: String,
        teamName: String
    ) async throws {
        try await userService.signUp(
            email: email,
            password: password,
            displayName: displayName,
            teamName: teamName
        )

        guard let user = authService.getCurrentUser() else {
            throw NSError(
                domain: "LoginManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in after sign up"]
            )
        }

        let session = try await sessionService.fetchUserRecord(for: user)
        await sessionStore.startSession(session)
    }

    func signUp(
        email: String,
        password: String,
        displayName: String,
        teamCode: String
    ) async throws {
        try await userService.signUp(
            email: email,
            password: password,
            displayName: displayName,
            teamCode: teamCode
        )

        guard let user = authService.getCurrentUser() else {
            throw NSError(
                domain: "LoginManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in after sign up"]
            )
        }

        let session = try await sessionService.fetchUserRecord(for: user)
        await sessionStore.startSession(session)
    }

    func createTeamForGoogleUser(
        displayName: String,
        teamName: String
    ) async throws {
        _ = try await userService.createTeamForAuthenticatedUser(
            displayName: displayName,
            teamName: teamName
        )

        guard let user = authService.getCurrentUser() else {
            throw NSError(
                domain: "LoginManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in after team creation"]
            )
        }

        let session = try await sessionService.fetchUserRecord(for: user)
        await sessionStore.startSession(session)
    }

    func joinTeamForGoogleUser(
        displayName: String,
        teamCode: String
    ) async throws {
        _ = try await userService.joinTeamForAuthenticatedUser(
            displayName: displayName,
            teamCode: teamCode
        )

        guard let user = authService.getCurrentUser() else {
            throw NSError(
                domain: "LoginManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in after joining team"]
            )
        }

        let session = try await sessionService.fetchUserRecord(for: user)
        await sessionStore.startSession(session)
    }
}

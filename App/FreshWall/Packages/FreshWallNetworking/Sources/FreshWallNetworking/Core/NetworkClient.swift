import Foundation

// MARK: - NetworkClient

public protocol NetworkClient {
    func configure(with configuration: NetworkConfiguration) async throws

    // Authentication
    func signIn(email: String, password: String) async throws -> AuthenticatedUser
    func signUp(email: String, password: String) async throws -> AuthenticatedUser
    func signOut() async throws
    func getCurrentUser() async -> AuthenticatedUser?

    // Team operations
    func createTeam(name: String, userId: String, userName: String) async throws -> String
    func getTeam(teamId: String) async throws -> Team
    func getTeamsForUser(userId: String) async throws -> [Team]

    // User operations
    func createUser(userId: String, email: String, name: String, teamId: String, role: UserRole) async throws
    func getUser(userId: String, teamId: String) async throws -> User
    func getUsersForTeam(teamId: String) async throws -> [User]
    func updateUser(userId: String, teamId: String, updates: UserUpdate) async throws
    func deleteUser(userId: String, teamId: String) async throws

    // Client operations
    func createClient(teamId: String, client: ClientCreate) async throws -> String
    func getClient(clientId: String, teamId: String) async throws -> Client
    func getClientsForTeam(teamId: String) async throws -> [Client]
    func updateClient(clientId: String, teamId: String, updates: ClientUpdate) async throws
    func deleteClient(clientId: String, teamId: String) async throws

    // Incident operations
    func createIncident(teamId: String, incident: IncidentCreate) async throws -> String
    func getIncident(incidentId: String, teamId: String) async throws -> Incident
    func getIncidentsForClient(clientId: String, teamId: String) async throws -> [Incident]
    func getIncidentsForTeam(teamId: String) async throws -> [Incident]
    func updateIncident(incidentId: String, teamId: String, updates: IncidentUpdate) async throws
    func deleteIncident(incidentId: String, teamId: String) async throws

    // Storage operations
    func uploadImage(data: Data, path: String) async throws -> URL
    func deleteImage(at url: URL) async throws

    // Invite operations
    func createInviteCode(teamId: String, createdBy: String) async throws -> String
    func validateInviteCode(_ code: String) async throws -> InviteCodeInfo
    func joinTeamWithCode(_ code: String, userId: String, userName: String, userEmail: String) async throws
}

// MARK: - AuthenticatedUser

public struct AuthenticatedUser {
    public let id: String
    public let email: String?

    public init(id: String, email: String?) {
        self.id = id
        self.email = email
    }
}

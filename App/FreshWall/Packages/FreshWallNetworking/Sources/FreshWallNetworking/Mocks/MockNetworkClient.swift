import Foundation

public final class MockNetworkClient: NetworkClient {
    // MARK: - Mock Data Storage

    private var currentUser: AuthenticatedUser?
    private var teams: [String: Team] = [:]
    private var users: [String: [String: User]] = [:] // [teamId: [userId: User]]
    private var clients: [String: [String: Client]] = [:] // [teamId: [clientId: Client]]
    private var incidents: [String: [String: Incident]] = [:] // [teamId: [incidentId: Incident]]
    private var inviteCodes: [String: String] = [:] // [code: teamId]

    // MARK: - Mock Configuration

    public var shouldFailAuth = false
    public var shouldFailNetworkCalls = false
    public var networkDelay: TimeInterval = 0.1

    public init() {
        seedMockData()
    }

    // MARK: - NetworkClient Implementation

    public func configure(with _: NetworkConfiguration) async throws {
        // Mock configuration - no-op
        try await simulateNetworkDelay()
    }

    // MARK: - Authentication

    public func signIn(email: String, password _: String) async throws -> AuthenticatedUser {
        try await simulateNetworkDelay()

        if shouldFailAuth {
            throw NetworkError.notAuthenticated
        }

        let user = AuthenticatedUser(id: "mock-user-123", email: email)
        currentUser = user
        return user
    }

    public func signUp(email: String, password _: String) async throws -> AuthenticatedUser {
        try await simulateNetworkDelay()

        if shouldFailAuth {
            throw NetworkError.serverError("Failed to create account")
        }

        let user = AuthenticatedUser(id: UUID().uuidString, email: email)
        currentUser = user
        return user
    }

    public func signOut() async throws {
        try await simulateNetworkDelay()
        currentUser = nil
    }

    public func getCurrentUser() async -> AuthenticatedUser? {
        return currentUser
    }

    // MARK: - Team Operations

    public func createTeam(name: String, userId: String, userName: String) async throws -> String {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        let teamId = UUID().uuidString
        let team = Team(
            id: teamId,
            name: name,
            teamCode: String(Int.random(in: 100_000 ... 999_999)),
            createdAt: Date()
        )

        teams[teamId] = team

        // Create the user in the team
        let user = User(
            id: userId,
            displayName: userName,
            email: currentUser?.email ?? "mock@example.com",
            role: .lead
        )

        if users[teamId] == nil {
            users[teamId] = [:]
        }
        users[teamId]?[userId] = user

        return teamId
    }

    public func getTeam(teamId: String) async throws -> Team {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        guard let team = teams[teamId] else {
            throw NetworkError.documentNotFound
        }

        return team
    }

    public func getTeamsForUser(userId: String) async throws -> [Team] {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        var userTeams: [Team] = []

        for (teamId, teamUsers) in users {
            if teamUsers[userId] != nil, let team = teams[teamId] {
                userTeams.append(team)
            }
        }

        return userTeams
    }

    // MARK: - User Operations

    public func createUser(userId: String, email: String, name: String, teamId: String, role: UserRole) async throws {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        let user = User(
            id: userId,
            displayName: name,
            email: email,
            role: role
        )

        if users[teamId] == nil {
            users[teamId] = [:]
        }
        users[teamId]?[userId] = user
    }

    public func getUser(userId: String, teamId: String) async throws -> User {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        guard let user = users[teamId]?[userId] else {
            throw NetworkError.documentNotFound
        }

        return user
    }

    public func getUsersForTeam(teamId: String) async throws -> [User] {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        let teamUsers = users[teamId]?.values.sorted { $0.displayName < $1.displayName } ?? []
        return Array(teamUsers)
    }

    public func updateUser(userId: String, teamId: String, updates: UserUpdate) async throws {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        guard var user = users[teamId]?[userId] else {
            throw NetworkError.documentNotFound
        }

        if let displayName = updates.displayName {
            user = User(
                id: user.id,
                displayName: displayName,
                email: user.email,
                role: user.role,
                isDeleted: user.isDeleted,
                deletedAt: user.deletedAt
            )
        }

        if let role = updates.role {
            user = User(
                id: user.id,
                displayName: user.displayName,
                email: user.email,
                role: role,
                isDeleted: user.isDeleted,
                deletedAt: user.deletedAt
            )
        }

        users[teamId]?[userId] = user
    }

    public func deleteUser(userId: String, teamId: String) async throws {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        guard var user = users[teamId]?[userId] else {
            throw NetworkError.documentNotFound
        }

        user = User(
            id: user.id,
            displayName: user.displayName,
            email: user.email,
            role: user.role,
            isDeleted: true,
            deletedAt: Date()
        )

        users[teamId]?[userId] = user
    }

    // MARK: - Client Operations

    public func createClient(teamId: String, client: ClientCreate) async throws -> String {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        let clientId = UUID().uuidString
        let newClient = Client(
            id: clientId,
            name: client.name,
            notes: client.notes,
            isDeleted: false,
            deletedAt: nil,
            createdAt: Date(),
            lastIncidentAt: Date()
        )

        if clients[teamId] == nil {
            clients[teamId] = [:]
        }
        clients[teamId]?[clientId] = newClient

        return clientId
    }

    public func getClient(clientId: String, teamId: String) async throws -> Client {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        guard let client = clients[teamId]?[clientId] else {
            throw NetworkError.documentNotFound
        }

        return client
    }

    public func getClientsForTeam(teamId: String) async throws -> [Client] {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        let teamClients = clients[teamId]?.values
            .filter { !$0.isDeleted }
            .sorted { $0.name < $1.name } ?? []

        return Array(teamClients)
    }

    public func updateClient(clientId: String, teamId: String, updates: ClientUpdate) async throws {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        guard var client = clients[teamId]?[clientId] else {
            throw NetworkError.documentNotFound
        }

        if let name = updates.name {
            client = Client(
                id: client.id,
                name: name,
                notes: client.notes,
                isDeleted: client.isDeleted,
                deletedAt: client.deletedAt,
                createdAt: client.createdAt,
                lastIncidentAt: client.lastIncidentAt
            )
        }

        if let notes = updates.notes {
            client = Client(
                id: client.id,
                name: client.name,
                notes: notes,
                isDeleted: client.isDeleted,
                deletedAt: client.deletedAt,
                createdAt: client.createdAt,
                lastIncidentAt: client.lastIncidentAt
            )
        }

        clients[teamId]?[clientId] = client
    }

    public func deleteClient(clientId: String, teamId: String) async throws {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        guard var client = clients[teamId]?[clientId] else {
            throw NetworkError.documentNotFound
        }

        client = Client(
            id: client.id,
            name: client.name,
            notes: client.notes,
            isDeleted: true,
            deletedAt: Date(),
            createdAt: client.createdAt,
            lastIncidentAt: client.lastIncidentAt
        )

        clients[teamId]?[clientId] = client
    }

    // MARK: - Incident Operations

    public func createIncident(teamId: String, incident: IncidentCreate) async throws -> String {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        let incidentId = UUID().uuidString
        let newIncident = Incident(
            id: incidentId,
            projectTitle: incident.projectTitle,
            clientId: incident.clientId,
            workerIds: incident.workerIds,
            description: incident.description,
            area: incident.area,
            createdAt: Date(),
            startTime: incident.startTime,
            endTime: incident.endTime,
            beforePhotos: incident.beforePhotos,
            afterPhotos: incident.afterPhotos,
            createdById: currentUser?.id ?? "mock-user",
            lastModifiedById: nil,
            lastModifiedAt: nil,
            billable: incident.billable,
            rate: incident.rate,
            status: incident.status,
            materialsUsed: incident.materialsUsed
        )

        if incidents[teamId] == nil {
            incidents[teamId] = [:]
        }
        incidents[teamId]?[incidentId] = newIncident

        // Update client's lastIncidentAt
        if let clientId = incident.clientId,
           var client = clients[teamId]?[clientId] {
            client = Client(
                id: client.id,
                name: client.name,
                notes: client.notes,
                isDeleted: client.isDeleted,
                deletedAt: client.deletedAt,
                createdAt: client.createdAt,
                lastIncidentAt: Date()
            )
            clients[teamId]?[clientId] = client
        }

        return incidentId
    }

    public func getIncident(incidentId: String, teamId: String) async throws -> Incident {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        guard let incident = incidents[teamId]?[incidentId] else {
            throw NetworkError.documentNotFound
        }

        return incident
    }

    public func getIncidentsForClient(clientId: String, teamId: String) async throws -> [Incident] {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        let teamIncidents = incidents[teamId]?.values
            .filter { $0.clientId == clientId }
            .sorted { $0.createdAt > $1.createdAt } ?? []

        return Array(teamIncidents)
    }

    public func getIncidentsForTeam(teamId: String) async throws -> [Incident] {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        let teamIncidents = incidents[teamId]?.values
            .sorted { $0.createdAt > $1.createdAt } ?? []

        return Array(teamIncidents)
    }

    public func updateIncident(incidentId: String, teamId: String, updates: IncidentUpdate) async throws {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        guard var incident = incidents[teamId]?[incidentId] else {
            throw NetworkError.documentNotFound
        }

        // Apply updates
        incident = Incident(
            id: incident.id,
            projectTitle: updates.projectTitle ?? incident.projectTitle,
            clientId: updates.clientId ?? incident.clientId,
            workerIds: updates.workerIds ?? incident.workerIds,
            description: updates.description ?? incident.description,
            area: updates.area ?? incident.area,
            createdAt: incident.createdAt,
            startTime: updates.startTime ?? incident.startTime,
            endTime: updates.endTime ?? incident.endTime,
            beforePhotos: updates.beforePhotos ?? incident.beforePhotos,
            afterPhotos: updates.afterPhotos ?? incident.afterPhotos,
            createdById: incident.createdById,
            lastModifiedById: currentUser?.id,
            lastModifiedAt: Date(),
            billable: updates.billable ?? incident.billable,
            rate: updates.rate ?? incident.rate,
            status: updates.status ?? incident.status,
            materialsUsed: updates.materialsUsed ?? incident.materialsUsed
        )

        incidents[teamId]?[incidentId] = incident
    }

    public func deleteIncident(incidentId: String, teamId: String) async throws {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        incidents[teamId]?.removeValue(forKey: incidentId)
    }

    // MARK: - Storage Operations

    public func uploadImage(data _: Data, path: String) async throws -> URL {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        // Return a mock URL
        return URL(string: "https://mock-storage.example.com/\(path)")!
    }

    public func deleteImage(at _: URL) async throws {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        // Mock deletion - no-op
    }

    // MARK: - Invite Operations

    public func createInviteCode(teamId: String, createdBy _: String) async throws -> String {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        let code = String(Int.random(in: 100_000 ... 999_999))
        inviteCodes[code] = teamId
        return code
    }

    public func validateInviteCode(_ code: String) async throws -> InviteCodeInfo {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        guard let teamId = inviteCodes[code],
              let team = teams[teamId] else {
            throw NetworkError.serverError("Invalid invite code")
        }

        return InviteCodeInfo(teamId: teamId, teamName: team.name)
    }

    public func joinTeamWithCode(_ code: String, userId: String, userName: String, userEmail: String) async throws {
        try await simulateNetworkDelay()
        try checkNetworkFailure()

        guard let teamId = inviteCodes[code] else {
            throw NetworkError.serverError("Invalid invite code")
        }

        let user = User(
            id: userId,
            displayName: userName,
            email: userEmail,
            role: .member
        )

        if users[teamId] == nil {
            users[teamId] = [:]
        }
        users[teamId]?[userId] = user
    }

    // MARK: - Helper Methods

    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))
    }

    private func checkNetworkFailure() throws {
        if shouldFailNetworkCalls {
            throw NetworkError.networkFailure(NSError(domain: "MockNetwork", code: -1))
        }
    }

    private func seedMockData() {
        // Create a mock team
        let teamId = "mock-team-123"
        teams[teamId] = Team(
            id: teamId,
            name: "Mock Team",
            teamCode: "123456",
            createdAt: Date()
        )

        // Create mock users
        users[teamId] = [
            "mock-user-123": User(
                id: "mock-user-123",
                displayName: "John Doe",
                email: "john@example.com",
                role: .lead
            ),
            "mock-user-456": User(
                id: "mock-user-456",
                displayName: "Jane Smith",
                email: "jane@example.com",
                role: .member
            ),
        ]

        // Create mock clients
        clients[teamId] = [
            "mock-client-1": Client(
                id: "mock-client-1",
                name: "ABC Corporation",
                notes: "Important client",
                isDeleted: false,
                deletedAt: nil,
                createdAt: Date().addingTimeInterval(-86400 * 30),
                lastIncidentAt: Date().addingTimeInterval(-86400)
            ),
            "mock-client-2": Client(
                id: "mock-client-2",
                name: "XYZ Industries",
                notes: nil,
                isDeleted: false,
                deletedAt: nil,
                createdAt: Date().addingTimeInterval(-86400 * 20),
                lastIncidentAt: Date().addingTimeInterval(-86400 * 5)
            ),
        ]

        // Create mock incidents
        incidents[teamId] = [
            "mock-incident-1": Incident(
                id: "mock-incident-1",
                projectTitle: "Downtown Cleanup",
                clientId: "mock-client-1",
                workerIds: ["mock-user-123", "mock-user-456"],
                description: "Graffiti removal on main street",
                area: 150.5,
                createdAt: Date().addingTimeInterval(-86400),
                startTime: Date().addingTimeInterval(-86400),
                endTime: Date().addingTimeInterval(-82800),
                beforePhotos: [],
                afterPhotos: [],
                createdById: "mock-user-123",
                lastModifiedById: nil,
                lastModifiedAt: nil,
                billable: true,
                rate: 75.0,
                status: "completed",
                materialsUsed: "Paint remover, brushes"
            ),
        ]
    }

    // MARK: - Public Test Helpers

    public func reset() {
        currentUser = nil
        teams.removeAll()
        users.removeAll()
        clients.removeAll()
        incidents.removeAll()
        inviteCodes.removeAll()
        seedMockData()
    }

    public func setCurrentUser(_ user: AuthenticatedUser?) {
        currentUser = user
    }
}

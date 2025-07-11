@testable import FreshWallNetworking
import Testing

struct FreshWallNetworkingTests {
    @Test("Mock network client can be created and configured")
    func mockClientCreation() async throws {
        let client = MockNetworkClient()
        let config = NetworkConfiguration.development

        try await client.configure(with: config)

        // Client should be ready to use
        let user = await client.getCurrentUser()
        #expect(user == nil) // No user logged in initially
    }

    @Test("Authentication flow works correctly")
    func authentication() async throws {
        let client = MockNetworkClient()
        try await client.configure(with: .development)

        // Sign up
        let signedUpUser = try await client.signUp(email: "test@example.com", password: "password123")
        #expect(signedUpUser.email == "test@example.com")
        #expect(signedUpUser.id != "")

        // Current user should be set
        let currentUser = await client.getCurrentUser()
        #expect(currentUser?.id == signedUpUser.id)

        // Sign out
        try await client.signOut()
        let userAfterSignOut = await client.getCurrentUser()
        #expect(userAfterSignOut == nil)

        // Sign in
        let signedInUser = try await client.signIn(email: "test@example.com", password: "password123")
        #expect(signedInUser.email == "test@example.com")
    }

    @Test("Team operations work correctly")
    func teamOperations() async throws {
        let client = MockNetworkClient()
        try await client.configure(with: .development)

        // Sign in first
        let user = try await client.signIn(email: "test@example.com", password: "password123")

        // Create team
        let teamId = try await client.createTeam(
            name: "Test Team",
            userId: user.id,
            userName: "Test User"
        )
        #expect(!teamId.isEmpty)

        // Get team
        let team = try await client.getTeam(teamId: teamId)
        #expect(team.name == "Test Team")
        #expect(team.id == teamId)

        // Get teams for user
        let userTeams = try await client.getTeamsForUser(userId: user.id)
        #expect(userTeams.count >= 1)
        #expect(userTeams.contains { $0.id == teamId })
    }

    @Test("Client CRUD operations work correctly")
    func clientOperations() async throws {
        let networkClient = MockNetworkClient()
        try await networkClient.configure(with: .development)

        let user = try await networkClient.signIn(email: "test@example.com", password: "password123")
        let teamId = "mock-team-123"

        // Create client
        let clientCreate = ClientCreate(name: "New Client", notes: "Important notes")
        let clientId = try await networkClient.createClient(teamId: teamId, client: clientCreate)
        #expect(!clientId.isEmpty)

        // Get client
        let client = try await networkClient.getClient(clientId: clientId, teamId: teamId)
        #expect(client.name == "New Client")
        #expect(client.notes == "Important notes")

        // Update client
        let updates = ClientUpdate(name: "Updated Client")
        try await networkClient.updateClient(clientId: clientId, teamId: teamId, updates: updates)

        let updatedClient = try await networkClient.getClient(clientId: clientId, teamId: teamId)
        #expect(updatedClient.name == "Updated Client")
        #expect(updatedClient.notes == "Important notes") // Notes unchanged

        // Get all clients
        let clients = try await networkClient.getClientsForTeam(teamId: teamId)
        #expect(clients.contains { $0.id == clientId })

        // Delete client
        try await networkClient.deleteClient(clientId: clientId, teamId: teamId)

        let deletedClient = try await networkClient.getClient(clientId: clientId, teamId: teamId)
        #expect(deletedClient.isDeleted == true)
    }

    @Test("Incident operations work correctly")
    func incidentOperations() async throws {
        let client = MockNetworkClient()
        try await client.configure(with: .development)

        let user = try await client.signIn(email: "test@example.com", password: "password123")
        let teamId = "mock-team-123"
        let clientId = "mock-client-1"

        // Create incident
        let incidentCreate = IncidentCreate(
            projectTitle: "Test Cleanup",
            clientId: clientId,
            workerIds: [user.id],
            description: "Test incident",
            area: 100.0,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            billable: true,
            rate: 50.0,
            status: "open",
            materialsUsed: "Test materials"
        )

        let incidentId = try await client.createIncident(teamId: teamId, incident: incidentCreate)
        #expect(!incidentId.isEmpty)

        // Get incident
        let incident = try await client.getIncident(incidentId: incidentId, teamId: teamId)
        #expect(incident.projectTitle == "Test Cleanup")
        #expect(incident.clientId == clientId)
        #expect(incident.area == 100.0)

        // Update incident
        let updates = IncidentUpdate(projectTitle: "Updated Cleanup", status: "completed")
        try await client.updateIncident(incidentId: incidentId, teamId: teamId, updates: updates)

        let updatedIncident = try await client.getIncident(incidentId: incidentId, teamId: teamId)
        #expect(updatedIncident.projectTitle == "Updated Cleanup")
        #expect(updatedIncident.status == "completed")

        // Get incidents for client
        let clientIncidents = try await client.getIncidentsForClient(clientId: clientId, teamId: teamId)
        #expect(clientIncidents.contains { $0.id == incidentId })

        // Get incidents for team
        let teamIncidents = try await client.getIncidentsForTeam(teamId: teamId)
        #expect(teamIncidents.contains { $0.id == incidentId })
    }

    @Test("Network error handling works correctly")
    func errorHandling() async throws {
        let client = MockNetworkClient()
        try await client.configure(with: .development)

        // Test authentication failure
        client.shouldFailAuth = true

        await #expect(throws: NetworkError.self) {
            _ = try await client.signIn(email: "test@example.com", password: "wrong")
        }

        // Test network failure
        client.shouldFailAuth = false
        client.shouldFailNetworkCalls = true

        await #expect(throws: NetworkError.self) {
            _ = try await client.getTeam(teamId: "any-id")
        }
    }

    @Test("Invite code operations work correctly")
    func inviteOperations() async throws {
        let client = MockNetworkClient()
        try await client.configure(with: .development)

        let user = try await client.signIn(email: "test@example.com", password: "password123")
        let teamId = "mock-team-123"

        // Create invite code
        let inviteCode = try await client.createInviteCode(teamId: teamId, createdBy: user.id)
        #expect(!inviteCode.isEmpty)
        #expect(inviteCode.count == 6) // Should be 6 digits

        // Validate invite code
        let inviteInfo = try await client.validateInviteCode(inviteCode)
        #expect(inviteInfo.teamId == teamId)
        #expect(inviteInfo.teamName == "Mock Team")

        // Join team with code
        let newUserId = "new-user-123"
        try await client.joinTeamWithCode(
            inviteCode,
            userId: newUserId,
            userName: "New User",
            userEmail: "newuser@example.com"
        )

        // Verify user was added
        let users = try await client.getUsersForTeam(teamId: teamId)
        #expect(users.contains { $0.id == newUserId })
    }

    @Test("Storage operations return mock URLs")
    func storageOperations() async throws {
        let client = MockNetworkClient()
        try await client.configure(with: .development)

        let imageData = Data("fake-image-data".utf8)
        let path = "images/test-image.jpg"

        // Upload image
        let url = try await client.uploadImage(data: imageData, path: path)
        #expect(url.absoluteString.contains("mock-storage.example.com"))
        #expect(url.absoluteString.contains(path))

        // Delete image (should not throw)
        try await client.deleteImage(at: url)
    }
}

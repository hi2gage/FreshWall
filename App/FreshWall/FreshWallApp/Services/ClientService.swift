@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - ClientServiceProtocol

/// Protocol defining operations for fetching and managing Client entities.
protocol ClientServiceProtocol: Sendable {
    /// Fetches active clients for the current team.
    func fetchClients() async throws -> [Client]
    /// Adds a new client using an input value object.
    /// - Returns: The ID of the newly created client.
    func addClient(_ input: AddClientInput) async throws -> String
    /// Updates an existing client using an input value object.
    func updateClient(_ clientId: String, with input: UpdateClientInput) async throws
    /// Deletes an existing client.
    func deleteClient(_ clientId: String) async throws
}

// MARK: - ClientService

/// Service to fetch and manage ``Client`` entities for the current team.
///
/// All direct Firestore interaction is delegated to a ``ClientModelServiceProtocol``
/// instance to keep this type focused on higher level business logic.
struct ClientService: ClientServiceProtocol {
    private let modelService: ClientModelServiceProtocol
    private let session: UserSession

    /// Initializes the service.
    /// - Parameters:
    ///   - firestore: Firestore instance used by the default ``ClientModelService``.
    ///   - modelService: Optional custom model service for testing.
    ///   - session: The current user session providing team context.
    init(
        modelService: ClientModelServiceProtocol,
        session: UserSession
    ) {
        self.modelService = modelService
        self.session = session
    }

    /// Fetches active clients for the current team from Firestore.
    func fetchClients() async throws -> [Client] {
        let teamId = session.teamId
        let dtos = try await modelService.fetchClients(teamId: teamId)
        return dtos.map { Client(dto: $0) }
    }

    /// Adds a new client using an input value object.
    /// - Returns: The ID of the newly created client.
    func addClient(_ input: AddClientInput) async throws -> String {
        let teamId = session.teamId

        let newDoc = modelService.newClientDocument(teamId: teamId)
        let newClient = ClientDTO(
            id: newDoc.documentID,
            name: input.name,
            notes: input.notes,
            isDeleted: false,
            deletedAt: nil,
            createdAt: Timestamp(date: Date()),
            lastIncidentAt: input.lastIncidentAt
        )
        try await modelService.setClient(newClient, at: newDoc)
        return newDoc.documentID
    }

    /// Updates an existing client document in Firestore.
    func updateClient(_ clientId: String, with input: UpdateClientInput) async throws {
        let teamId = session.teamId

        var data: [String: Any] = ["name": input.name]
        if let notes = input.notes {
            data["notes"] = notes
        } else {
            data["notes"] = FieldValue.delete()
        }

        try await modelService.updateClient(id: clientId, teamId: teamId, data: data)
    }

    /// Deletes an existing client document from Firestore.
    func deleteClient(_ clientId: String) async throws {
        let teamId = session.teamId
        try await modelService.deleteClient(id: clientId, teamId: teamId)
    }
}

// MARK: ClientService.Errors

extension ClientService {
    enum Errors: Error {
        case missingTeamId
    }
}

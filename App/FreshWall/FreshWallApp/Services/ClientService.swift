@preconcurrency import FirebaseFirestore
import Foundation

/// Protocol defining operations for fetching and managing Client entities.
protocol ClientServiceProtocol: Sendable {
    /// Fetches active clients for the current team.
    func fetchClients() async throws -> [Client]
    /// Adds a new client using an input value object.
    func addClient(_ input: AddClientInput) async throws
}

/// Service to fetch and manage Client entities from Firestore.
struct ClientService: ClientServiceProtocol {
    private let firestore: Firestore
    private let session: UserSession

    /// Initializes the service with the given UserService for team context.
    /// Initializes the service with a Firestore instance and UserService for team context.
    init(firestore: Firestore, session: UserSession) {
        self.firestore = firestore
        self.session = session
    }

    /// Fetches active clients for the current team from Firestore.
    func fetchClients() async throws -> [Client] {
        let teamId = session.teamId

        let snapshot = try await firestore
            .collection("teams")
            .document(teamId)
            .collection("clients")
            .whereField("isDeleted", isEqualTo: false)
            .getDocuments()
        let fetched: [Client] = try snapshot.documents.compactMap {
            try $0.data(as: Client.self)
        }
        return fetched
    }

    /// Adds a new client using an input value object.
    func addClient(_ input: AddClientInput) async throws {
        let teamId = session.teamId

        let clientsRef = firestore
            .collection("teams")
            .document(teamId)
            .collection("clients")
        let newDoc = clientsRef.document()
        let newClient = Client(
            id: newDoc.documentID,
            name: input.name,
            notes: input.notes,
            isDeleted: false,
            deletedAt: nil,
            createdAt: Timestamp(date: Date())
        )
        try newDoc.setData(from: newClient)
    }
}

extension ClientService {
    enum Errors: Error {
        case missingTeamId
    }
}

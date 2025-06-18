@preconcurrency import FirebaseFirestore
import Foundation

/// Protocol defining operations for fetching and managing Client entities.
protocol ClientServiceProtocol: Sendable {
    /// Fetches active clients for the current team.
    func fetchClients(sortedBy sortOption: ClientSortOption) async throws -> [ClientDTO]
    /// Adds a new client using an input value object.
    func addClient(_ input: AddClientInput) async throws
}

/// Service to fetch and manage Client entities from Firestore.
struct ClientService: ClientServiceProtocol {
    private let firestore: Firestore
    private let session: UserSession

    /// Initializes the service with a `Firestore` instance and `UserSession` for team context.
    init(firestore: Firestore, session: UserSession) {
        self.firestore = firestore
        self.session = session
    }

    /// Fetches active clients for the current team from Firestore.
    func fetchClients(sortedBy _: ClientSortOption) async throws -> [ClientDTO] {
        let teamId = session.teamId

        let snapshot = try await firestore
            .collection("teams")
            .document(teamId)
            .collection("clients")
//            .whereField("isDeleted", isEqualTo: false)
//            .order(by: sortOption.field, descending: sortOption.isDescending)
            .getDocuments()
        print(snapshot)

        let fetched: [ClientDTO] = try snapshot.documents.compactMap {
            try $0.data(as: ClientDTO.self)
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
        let newClient = ClientDTO(
            id: newDoc.documentID,
            name: input.name,
            notes: input.notes,
            isDeleted: false,
            deletedAt: nil,
            createdAt: Timestamp(date: Date()),
            lastIncidentAt: input.lastIncidentAt
        )
        try newDoc.setData(from: newClient)
    }
}

extension ClientService {
    enum Errors: Error {
        case missingTeamId
    }
}

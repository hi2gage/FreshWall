import FirebaseFirestore
import Foundation
import Observation

/// Protocol defining operations for fetching and managing Client entities.
protocol ClientServiceProtocol {
    /// The array of fetched clients for the current team.
    var clients: [Client] { get }
    /// Fetches active clients for the current team.
    func fetchClients() async
    /// Adds a new client with the given name and optional notes.
    func addClient(name: String, notes: String?) async throws
}

/// Service to fetch and manage Client entities from Firestore.
@Observable
final class ClientService: ClientServiceProtocol {
    private let database: Firestore
    private let userService: UserService

    /// Published list of clients for the current team.
    var clients: [Client] = []

    /// Initializes the service with the given UserService for team context.
    /// Initializes the service with a Firestore instance and UserService for team context.
    init(firestore: Firestore, userService: UserService) {
        database = firestore
        self.userService = userService
    }

    /// Fetches active clients for the current team from Firestore.
    func fetchClients() async {
        guard let teamId = userService.teamId else { return }
        do {
            let snapshot = try await database
                .collection("teams")
                .document(teamId)
                .collection("clients")
                .whereField("isDeleted", isEqualTo: false)
                .getDocuments()
            let fetched: [Client] = try snapshot.documents.compactMap {
                try $0.data(as: Client.self)
            }
            clients = fetched
        } catch {
            print("ClientService.fetchClients error:", error)
        }
    }

    /// Adds a new client document to Firestore under the current team.
    ///
    /// - Parameters:
    ///   - name: The display name of the new client.
    ///   - notes: Optional notes for the client.
    /// - Throws: An error if the Firestore write fails or teamId is missing.
    func addClient(name: String, notes: String?) async throws {
        guard let teamId = userService.teamId else {
            throw NSError(domain: "ClientService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Missing team ID"])
        }
        let clientsRef = database
            .collection("teams")
            .document(teamId)
            .collection("clients")
        let newDoc = clientsRef.document()
        let newClient = Client(
            id: newDoc.documentID,
            name: name,
            notes: notes,
            isDeleted: false,
            deletedAt: nil,
            createdAt: Timestamp(date: Date())
        )
        try await newDoc.setData(from: newClient)
        await fetchClients()
    }
}

import Foundation
import FirebaseFirestore
import Observation

/// Service to fetch and manage Client entities from Firestore.
@Observable
final class ClientService {
    private let database = Firestore.firestore()
    private let userService: UserService

    /// Published list of clients for the current team.
    var clients: [Client] = []

    /// Initializes the service with the given UserService for team context.
    init(userService: UserService) {
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
}

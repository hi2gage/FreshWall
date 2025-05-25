import Foundation
import FirebaseFirestore
import Observation

/// Service to fetch and manage Incident entities from Firestore.
@Observable
final class IncidentService {
    private let database = Firestore.firestore()
    private let userService: UserService

    /// Published list of incidents for the current team.
    var incidents: [Incident] = []

    /// Initializes the service with the given UserService for team context.
    init(userService: UserService) {
        self.userService = userService
    }

    /// Fetches active incidents for the current team from Firestore.
    func fetchIncidents() async {
        guard let teamId = userService.teamId else { return }
        do {
            let snapshot = try await database
                .collection("teams")
                .document(teamId)
                .collection("incidents")
                .getDocuments()
            let fetched: [Incident] = try snapshot.documents.compactMap {
                try $0.data(as: Incident.self)
            }
            incidents = fetched
        } catch {
            print("IncidentService.fetchIncidents error:", error)
        }
    }
}

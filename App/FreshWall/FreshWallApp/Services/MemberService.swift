import Foundation
import FirebaseFirestore
import FirebaseFirestore
import Observation

/// Service to fetch and manage User (member) entities from Firestore.
@Observable
final class MemberService {
    private let database = Firestore.firestore()
    private let userService: UserService

    /// Published list of members for the current team.
    var members: [User] = []

    /// Initializes the service with the given UserService for team context.
    init(userService: UserService) {
        self.userService = userService
    }

    /// Fetches active members for the current team from Firestore.
    func fetchMembers() async {
        guard let teamId = userService.teamId else { return }
        do {
            let snapshot = try await database
                .collection("teams")
                .document(teamId)
                .collection("users")
                .whereField("isDeleted", isEqualTo: false)
                .getDocuments()
            let fetched: [User] = try snapshot.documents.compactMap {
                try $0.data(as: User.self)
            }
            members = fetched
        } catch {
            print("MemberService.fetchMembers error:", error)
        }
    }
}

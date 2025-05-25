import FirebaseFirestore
import Foundation
import Observation

/// Protocol defining operations for fetching and managing User (team member) entities.
protocol MemberServiceProtocol {
    /// The array of fetched team members.
    var members: [User] { get }
    /// Fetches active members for the current team.
    func fetchMembers() async
    /// Adds a new team member document to Firestore.
    func addMember(_ member: User) async throws
}

/// Service to fetch and manage User (member) entities from Firestore.
@Observable
final class MemberService: MemberServiceProtocol {
    private let database: Firestore
    private let userService: UserService

    /// Published list of members for the current team.
    var members: [User] = []

    /// Initializes the service with the given UserService for team context.
    /// Initializes the service with a Firestore instance and UserService for team context.
    init(firestore: Firestore, userService: UserService) {
        database = firestore
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

    /// Adds a new member document to Firestore under the current team.
    ///
    /// - Parameter member: The `User` model to add (with `id == nil`).
    /// - Throws: An error if the Firestore write fails or teamId is missing.
    func addMember(_ member: User) async throws {
        guard let teamId = userService.teamId else {
            throw NSError(domain: "MemberService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Missing team ID"])
        }
        let usersRef = database
            .collection("teams")
            .document(teamId)
            .collection("users")
        let newDoc = usersRef.document()
        var newMember = member
        newMember.id = newDoc.documentID
        try await newDoc.setData(from: newMember)
        await fetchMembers()
    }
}

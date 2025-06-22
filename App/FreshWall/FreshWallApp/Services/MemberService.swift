@preconcurrency import FirebaseFirestore
import Foundation

/// Protocol defining operations for fetching and managing User (team member) entities.
protocol MemberServiceProtocol: Sendable {
    /// Fetches active members for the current team.
    func fetchMembers() async throws -> [Member]
    /// Adds a new team member document to Firestore.
    func addMember(_ input: AddMemberInput) async throws
}

/// Service to fetch and manage User (member) entities from Firestore.
struct MemberService: MemberServiceProtocol {
    private let firestore: Firestore
    private let session: UserSession

    /// Initializes the service with a `Firestore` instance and `UserSession` for team context.
    init(firestore: Firestore, session: UserSession) {
        self.firestore = firestore
        self.session = session
    }

    /// Fetches active members for the current team from Firestore.
    func fetchMembers() async throws -> [Member] {
        let teamId = session.teamId

        let snapshot = try await firestore
            .collection("teams")
            .document(teamId)
            .collection("users")
            .whereField("isDeleted", isEqualTo: false)
            .getDocuments()
        let fetched: [UserDTO] = try snapshot.documents.compactMap {
            try $0.data(as: UserDTO.self)
        }
        return fetched.map { Member(dto: $0) }
    }

    /// Adds a new member document to Firestore under the current team.
    ///
    /// - Parameter member: The `User` model to add (with `id == nil`).
    /// - Throws: An error if the Firestore write fails or teamId is missing.
    func addMember(_ input: AddMemberInput) async throws {
        let teamId = session.teamId

        let usersRef = firestore
            .collection("teams")
            .document(teamId)
            .collection("users")
        let newDoc = usersRef.document()
        let newMember = UserDTO(
            id: newDoc.documentID,
            displayName: input.displayName,
            email: input.email,
            role: input.role,
            isDeleted: false,
            deletedAt: nil
        )
        try newDoc.setData(from: newMember)
    }
}

extension MemberService {
    enum Errors: Error {
        case missingTeamId
    }
}

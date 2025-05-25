import FirebaseFirestore
import Foundation

/// A team represents a group under which all data is scoped.
struct Team: Codable, Identifiable {
    /// Firestore-generated document identifier for the team.
    @DocumentID var id: String?
    /// Name of the team.
    var name: String
    /// Identifiable code for joining an exisiting team
    var teamCode: String
    /// Timestamp when this team was created.
    var createdAt: Timestamp
}

enum TeamGenerator {
    static func make(
        teamName: String,
        teamCode: String = UUID().uuidString.prefix(6).uppercased()
    ) -> Team {
        .init(
            id: nil,
            name: teamName,
            teamCode: teamCode,
            createdAt: Timestamp()
        )
    }
}

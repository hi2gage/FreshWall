@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - TeamDTO

/// A team represents a group under which all data is scoped.
struct TeamDTO: Codable, Identifiable {
    /// Firestore-generated document identifier for the team.
    @DocumentID var id: String?
    /// Name of the team.
    var name: String
    /// Identifiable code for joining an exisiting team
    var teamCode: String
    /// Timestamp when this team was created.
    var createdAt: Timestamp
}

// MARK: - TeamGenerator

enum TeamGenerator {
    static func make(
        teamName: String,
        teamCode: String = UUID().uuidString.prefix(6).uppercased()
    ) -> TeamDTO {
        .init(
            id: nil,
            name: teamName,
            teamCode: teamCode,
            createdAt: Timestamp()
        )
    }
}

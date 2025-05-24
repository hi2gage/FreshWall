import Foundation
import FirebaseFirestore
import FirebaseFirestore

/// A team represents a group under which all data is scoped.
struct Team: Codable, Identifiable {
    /// Firestore-generated document identifier for the team.
    @DocumentID var id: String?
    /// Name of the team.
    var name: String
    /// Timestamp when this team was created.
    var createdAt: Timestamp
}

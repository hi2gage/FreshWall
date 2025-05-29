@preconcurrency import FirebaseFirestore
import Foundation

/// A customer or client associated with the team.
struct ClientDTO: Codable, Identifiable, Hashable {
    /// Firestore-generated document identifier for the client.
    @DocumentID var id: String?
    /// Name of the client.
    var name: String
    /// Optional additional notes about the client.
    var notes: String?
    /// Flag indicating whether the client is soft-deleted.
    var isDeleted: Bool
    /// Timestamp when the client was marked deleted (if applicable).
    var deletedAt: Timestamp?
    /// Timestamp when this client was created.
    var createdAt: Timestamp
}


import FirebaseFirestore
import Foundation

/// Domain model representing a client used by the UI layer.
struct Client: Identifiable, Hashable, Sendable {
    var id: String?
    var name: String
    var notes: String?
    var isDeleted: Bool
    var deletedAt: Timestamp?
    var createdAt: Timestamp
    var lastIncidentAt: Timestamp
}

extension Client {
    /// Creates a domain model from a DTO.
    init(dto: ClientDTO) {
        self.id = dto.id
        self.name = dto.name
        self.notes = dto.notes
        self.isDeleted = dto.isDeleted
        self.deletedAt = dto.deletedAt
        self.createdAt = dto.createdAt
        self.lastIncidentAt = dto.lastIncidentAt
    }

    /// Converts the domain model back to a DTO for persistence.
    var dto: ClientDTO {
        ClientDTO(
            id: id,
            name: name,
            notes: notes,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
            createdAt: createdAt,
            lastIncidentAt: lastIncidentAt
        )
    }
}

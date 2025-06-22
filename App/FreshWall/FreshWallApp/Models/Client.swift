import FirebaseFirestore
import Foundation

// MARK: - Client

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
        id = dto.id
        name = dto.name
        notes = dto.notes
        isDeleted = dto.isDeleted
        deletedAt = dto.deletedAt
        createdAt = dto.createdAt
        lastIncidentAt = dto.lastIncidentAt
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

import FirebaseFirestore
import Foundation

// MARK: - Member

/// Domain model representing a team member used by the UI layer.
struct Member: Identifiable, Hashable, Sendable {
    var id: String?
    var displayName: String
    var email: String
    var role: UserRole
    var isDeleted: Bool
    var deletedAt: Timestamp?
}

extension Member {
    /// Creates a domain model from a DTO.
    init(dto: UserDTO) {
        id = dto.id
        displayName = dto.displayName
        email = dto.email
        role = dto.role
        isDeleted = dto.isDeleted
        deletedAt = dto.deletedAt
    }

    /// Converts the domain model back to a DTO for persistence.
    var dto: UserDTO {
        UserDTO(
            id: id,
            displayName: displayName,
            email: email,
            role: role,
            isDeleted: isDeleted,
            deletedAt: deletedAt
        )
    }
}

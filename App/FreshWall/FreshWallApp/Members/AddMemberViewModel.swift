import Foundation
import Observation

/// ViewModel for AddMemberView, manages form state and saving.
@MainActor
@Observable
final class AddMemberViewModel {
    /// Full name of the new member.
    var displayName: String = ""
    /// Email of the new member.
    var email: String = ""
    /// Role of the new member.
    var role: UserRole = .member
    private let service: MemberServiceProtocol

    /// Validation: displayName and email must not be empty.
    var isValid: Bool {
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty &&
            !email.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(service: MemberServiceProtocol) {
        self.service = service
    }

    /// Saves the new member via the service.
    func save() async throws {
        let member = UserDTO(
            id: nil,
            displayName: displayName,
            email: email,
            role: role,
            isDeleted: false,
            deletedAt: nil
        )
        try await service.addMember(member)
    }
}

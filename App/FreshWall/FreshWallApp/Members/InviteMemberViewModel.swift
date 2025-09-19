import Foundation
import Observation

// MARK: - LoadingState

enum LoadingState<Value> {
    case idle
    case loading
    case success(Value)
    case failure(Error)
}

// MARK: - InviteMemberViewModel

@MainActor
@Observable
final class InviteMemberViewModel {
    // MARK: - Published State

    var state: LoadingState<InviteCode> = .idle

    // MARK: - Dependencies

    private let service: InviteCodeGenerating

    // MARK: - Initialization

    init(service: InviteCodeGenerating) {
        self.service = service
    }

    // MARK: - Actions

    func generateInviteCode(teamId: String, for role: UserRole = .fieldWorker, maxUses: Int = 10) async {
        state = .loading

        do {
            let inviteCode = try await service.generateInviteCode(teamId: teamId, role: role, maxUses: maxUses)
            state = .success(inviteCode)
        } catch {
            state = .failure(error)
        }
    }

    func retryGeneration(teamId: String) async {
        await generateInviteCode(teamId: teamId)
    }

    // MARK: - Computed Properties

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }
}

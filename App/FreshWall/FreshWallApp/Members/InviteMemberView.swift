import SwiftUI

struct InviteMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: InviteMemberViewModel
    @State private var selectedRole: UserRole = .fieldWorker
    @State private var maxUses: Int = 10
    @State private var showingOptions = false

    private let userSession: UserSession

    init(userSession: UserSession, service: InviteCodeGenerating) {
        self.userSession = userSession
        _viewModel = State(wrappedValue: InviteMemberViewModel(service: service))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch viewModel.state {
                case .idle:
                    emptyStateView
                case .loading:
                    loadingView
                case let .success(inviteCode):
                    inviteCodeView(inviteCode)
                case let .failure(error):
                    errorView(error)
                }
            }
            .padding()
        }
        .navigationTitle("Invite Member")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Options") {
                    showingOptions = true
                }
                .disabled(viewModel.isLoading)
            }
        }
        .sheet(isPresented: $showingOptions) {
            inviteOptionsSheet
        }
        .task {
            await viewModel.generateInviteCode(teamId: userSession.teamId, for: selectedRole, maxUses: maxUses)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Generating invite code...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    // MARK: - Error View

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Failed to Generate Code")
                .font(.headline)

            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await viewModel.retryGeneration(teamId: userSession.teamId)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    // MARK: - Invite Code View

    private func inviteCodeView(_ inviteCode: InviteCode) -> some View {
        VStack(spacing: 24) {
            // Status indicator
            if inviteCode.isValid {
                Label("Active Invite Code", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(.green)
            } else {
                Label("Expired Invite Code", systemImage: "exclamationmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(.red)
            }

            // Code display
            VStack(spacing: 12) {
                Text("Team Code")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(inviteCode.code)
                    .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }

            // Expiration info
            VStack(spacing: 8) {
                Text("Expires: \(inviteCode.formattedExpirationDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("\(inviteCode.maxUses) people can use this invite")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Action buttons
            VStack(spacing: 12) {
                ShareLink(item: inviteCode.shareMessage) {
                    Text("Share Invite")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                AsyncButton {
                    await viewModel.generateInviteCode(
                        teamId: userSession.teamId,
                        for: selectedRole,
                        maxUses: maxUses
                    )
                } label: {
                    Text("Generate New Code")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: 200)
        }
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Ready to Invite")
                .font(.headline)

            Text("Tap 'Options' to customize your invite settings")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Generate Invite Code") {
                Task {
                    await viewModel.generateInviteCode(teamId: userSession.teamId, for: selectedRole, maxUses: maxUses)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    // MARK: - Options Sheet

    private var inviteOptionsSheet: some View {
        NavigationStack {
            Form {
                Section("Invite Settings") {
                    Picker("Role", selection: $selectedRole) {
                        Text("Field Worker").tag(UserRole.fieldWorker)
                        Text("Team Lead").tag(UserRole.manager)
                    }

                    Stepper("Max Uses: \(maxUses)", value: $maxUses, in: 1 ... 100)
                }

                Section {
                    Button("Generate New Code") {
                        showingOptions = false
                        Task {
                            await viewModel.generateInviteCode(
                                teamId: userSession.teamId,
                                for: selectedRole,
                                maxUses: maxUses
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Invite Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingOptions = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            InviteMemberView(
                userSession: UserSession(
                    userId: "preview-uid",
                    displayName: "Preview User",
                    teamId: "preview-team-id",
                    role: .manager
                ),
                service: MockInviteCodeGenerator()
            )
        }
    }
}

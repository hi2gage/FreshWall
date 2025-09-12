import FirebaseFirestore
import SwiftUI

// MARK: - MemberDetailView

/// A view displaying detailed information for a specific team member.
struct MemberDetailView: View {
    let member: Member
    let currentUserSession: UserSession
    @State private var showingRoleChangeAlert = false
    @State private var selectedNewRole: UserRole = .fieldWorker

    /// Permission checker for current user
    private var permissions: PermissionChecker {
        PermissionChecker(userRole: currentUserSession.role)
    }

    /// Whether the current user can modify this member's role
    private var canChangeRole: Bool {
        permissions.canChangeUserRoles && permissions.canModifyUser(with: member.role)
    }

    var body: some View {
        List {
            Section("Member Information") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(member.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(member.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                HStack {
                    Text("Role")
                    Spacer()
                    HStack {
                        Text(member.role.displayName)
                            .foregroundColor(roleColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(roleColor.opacity(0.15))
                            .cornerRadius(6)

                        if canChangeRole {
                            Button("Change") {
                                selectedNewRole = member.role
                                showingRoleChangeAlert = true
                            }
                            .font(.caption)
                        }
                    }
                }
            }

            // Role Permissions Section
            Section("Role Permissions") {
                let memberPermissions = PermissionChecker(userRole: member.role)

                VStack(alignment: .leading, spacing: 8) {
                    Text(memberPermissions.permissionDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    PermissionRow(title: "Manage Incidents", hasPermission: memberPermissions.canCreateIncidents)
                    PermissionRow(title: "Manage Clients", hasPermission: memberPermissions.canEditClients)
                    PermissionRow(title: "Manage Team Members", hasPermission: memberPermissions.canManageTeamMembers)
                    PermissionRow(title: "Generate Reports", hasPermission: memberPermissions.canGenerateReports)
                    PermissionRow(title: "System Administration", hasPermission: memberPermissions.canAccessSystemSettings)
                }
            }

            // Status Section
            if member.isDeleted {
                Section("Status") {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("This member has been removed")
                            .foregroundColor(.red)
                    }

                    if let deletedAt = member.deletedAt {
                        HStack {
                            Text("Removed on")
                            Spacer()
                            Text(deletedAt.dateValue(), style: .date)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Member Details")
        .refreshable {
            // No-op until member service supports reloading a single member
        }
        .alert("Change Role", isPresented: $showingRoleChangeAlert) {
            Button("Admin") { selectedNewRole = .admin }
            Button("Manager") { selectedNewRole = .manager }
            Button("Field Worker") { selectedNewRole = .fieldWorker }
            Button("Cancel", role: .cancel) {}
            Button("Change Role") {
                // TODO: Implement role change functionality
                // This would call a service method to update the user's role
            }
        } message: {
            Text("Select a new role for \(member.displayName)")
        }
    }

    /// Color for the role badge
    private var roleColor: Color {
        switch member.role {
        case .admin:
            .red
        case .manager:
            .blue
        case .fieldWorker:
            .green
        default:
            .gray
        }
    }
}

// MARK: - PermissionRow

/// A row showing whether a specific permission is granted or not
private struct PermissionRow: View {
    let title: String
    let hasPermission: Bool

    var body: some View {
        HStack {
            Image(systemName: hasPermission ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundColor(hasPermission ? .green : .red)
                .font(.caption)

            Text(title)
                .font(.caption)
                .foregroundColor(hasPermission ? .primary : .secondary)

            Spacer()
        }
    }
}

#Preview {
    let sampleMember = Member(
        id: "member123",
        displayName: "Jane Doe",
        email: "jane@example.com",
        role: .manager,
        isDeleted: false,
        deletedAt: nil
    )

    let sampleSession = UserSession(
        userId: "current_user",
        displayName: "Current User",
        teamId: "team123",
        role: .admin
    )

    FreshWallPreview {
        NavigationStack {
            MemberDetailView(
                member: sampleMember,
                currentUserSession: sampleSession
            )
        }
    }
}

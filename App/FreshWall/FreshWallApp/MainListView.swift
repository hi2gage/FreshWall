import SwiftUI

/// The main dashboard view presenting navigation to various resource lists.
/// The main dashboard view presenting navigation to various resource lists.
struct MainListView: View {
    @Environment(RouterPath.self) private var routerPath

    /// Called when the user taps "Log Out".
    let sessionStore: AuthenticatedSessionStore

    /// Permission checker for current user
    private var permissions: PermissionChecker {
        sessionStore.permissions
    }

    var body: some View {
        ZStack {
            List {
                // Welcome section with role indicator
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome \(sessionStore.session.displayName)")
                        .font(.headline)
                    Text(sessionStore.session.role.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                }
                .padding(.vertical, 4)

                // Incidents section - available to all roles
                if permissions.canViewIncidents {
                    Section(header: Text("Incidents")) {
                        Button("View Incidents") {
                            routerPath.push(.incidentsList)
                        }
                    }
                }

                // Clients section - visible based on permissions
                if permissions.canViewClients {
                    Section(header: Text("Clients")) {
                        Button("View Clients") {
                            routerPath.push(.clientsList)
                        }
                    }
                }

                // Members section - visible based on permissions
                if permissions.canViewTeamMembers {
                    Section(header: Text("Team")) {
                        Button("View Members") {
                            routerPath.push(.membersList)
                        }
                    }
                }

                // Admin/Manager specific features
                if permissions.canViewAnalytics {
                    Section(header: Text("Management")) {
                        if permissions.canGenerateReports {
                            Button("Generate Reports") {
                                // TODO: Navigate to reports view
                            }
                        }

                        if permissions.canViewAnalytics {
                            Button("Team Analytics") {
                                // TODO: Navigate to analytics view
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)

            // Floating + button
            if permissions.canCreateIncidents {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            routerPath.push(.addIncident)
                        }) {
                            Image(systemName: "camera")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 68, height: 68)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4, x: 0, y: 2)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    routerPath.push(.settings)
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            MainListView(
                sessionStore: AuthenticatedSessionStore(
                    sessionStore: SessionStore(),
                    session: .init(userId: "preview", displayName: "Preview User", teamId: "preview-team", role: .admin)
                )
            )
        }
    }
}

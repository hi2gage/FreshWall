import SwiftUI

/// The main dashboard view presenting navigation to various resource lists.
/// The main dashboard view presenting navigation to various resource lists.
struct MainListView: View {
    @Environment(RouterPath.self) private var routerPath
    @State private var showingComingSoonAlert = false

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
                if permissions.canGenerateReports {
                    Section(header: Text("Management")) {
                        Button("Generate Reports") {
                            showingComingSoonAlert = true
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
                        Button {
                            routerPath.push(.addIncident)
                        } label: {
                            Image(systemName: "plus")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.brightHighlight)
                                .frame(width: 68, height: 68)
                                .background(Color.freshWallOrange)
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
                Button {
                    routerPath.push(.settings)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .alert("Coming Soon", isPresented: $showingComingSoonAlert) {
            Button("OK") {}
        } message: {
            Text("Report generation feature is coming soon! Stay tuned for updates.")
        }
    }
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            MainListView(
                sessionStore: AuthenticatedSessionStore(
                    sessionStore: SessionStore(),
                    session: .init(userId: "preview", displayName: "Preview User", teamId: "preview-team", role: .admin),
                    loginManager: LoginManager(
                        sessionStore: SessionStore(),
                        authService: AuthService(),
                        userService: UserService(),
                        sessionService: SessionService()
                    )
                )
            )
        }
    }
}

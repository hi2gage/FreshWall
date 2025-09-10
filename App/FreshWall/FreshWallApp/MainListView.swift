import SwiftUI

/// The main dashboard view presenting navigation to various resource lists.
/// The main dashboard view presenting navigation to various resource lists.
struct MainListView: View {
    @Environment(RouterPath.self) private var routerPath

    /// Called when the user taps "Log Out".
    let sessionStore: AuthenticatedSessionStore

    var body: some View {
        List {
            Text("Welcome \(sessionStore.session.displayName)")

            Section(header: Text("Clients")) {
                Button("View Clients") {
                    routerPath.push(.clientsList)
                }
            }
            Section(header: Text("Incidents")) {
                Button("View Incidents") {
                    routerPath.push(.incidentsList)
                }
            }
            Section(header: Text("Members")) {
                Button("View Members") {
                    routerPath.push(.membersList)
                }
            }
        }
        .listStyle(.insetGrouped)
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
                    session: .init(userId: "", displayName: "", teamId: "")
                )
            )
        }
    }
}

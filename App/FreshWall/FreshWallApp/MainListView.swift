import SwiftUI

/// The main dashboard view presenting navigation to various resource lists.
/// The main dashboard view presenting navigation to various resource lists.
struct MainListView: View {
    @Environment(RouterPath.self) private var routerPath

    /// Called when the user taps "Log Out".
    let sessionStore: SessionStore

    var body: some View {
        List {
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
                Button("Log Out") {
                    sessionStore.logout()
                }
            }
        }
    }
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            MainListView(
                sessionStore: SessionStore()
            )
        }
    }
}

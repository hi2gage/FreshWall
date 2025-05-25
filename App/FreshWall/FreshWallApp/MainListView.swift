import SwiftUI

/// The main dashboard view presenting navigation to various resource lists.
struct MainListView: View {
    let authService: AuthService
    let userService: UserService
    @Environment(RouterPath.self) private var routerPath

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
                    _ = authService.signOut()
                }
            }
        }
    }
}

struct MainListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MainListView(authService: AuthService(), userService: UserService())
        }
    }
}
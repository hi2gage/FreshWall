import SwiftData
import SwiftUI

@MainActor
@Observable
final class RouterPath {
    /// The navigation path for pushed destinations.
    var path: [RouterDestination] = []

    /// Pushes a new destination onto the navigation path.
    func push(_ item: RouterDestination) {
        path.append(item)
    }

    /// Pops the last destination from the navigation path.
    func pop() {
        _ = path.popLast()
    }
}

/// Destinations for navigation within the app.
enum RouterDestination: Hashable {
    /// Sign up screen for new users.
    case signup
    case signupWithTeam
    case clientsList
    case clientDetail(id: String)
    case incidentsList
    case incidentDetail(id: String)
    case membersList
    case memberDetail(id: String)
}

extension View {
    func withAppRouter(
        userService: UserService
    ) -> some View {
        navigationDestination(for: RouterDestination.self) { destination in
            switch destination {
            case .signup:
                SignupWithNewTeamView(userService: userService)
            case .signupWithTeam:
                SignupWithExistingTeamView(userService: userService)
            case .clientsList:
                ClientsListView()
            case .clientDetail(let id):
                ClientDetailView(clientId: id, userService: userService)
            case .incidentsList:
                IncidentsListView()
            case .incidentDetail(let id):
                IncidentDetailView(incidentId: id, userService: userService)
            case .membersList:
                MembersListView()
            case .memberDetail(let id):
                MemberDetailView(memberId: id, userService: userService)
            }
        }
    }
}

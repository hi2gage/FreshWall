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
    /// Screen for adding a new client.
    case addClient
    case clientDetail(id: String)
    case incidentsList
    /// Screen for adding a new incident.
    case addIncident
    case incidentDetail(id: String)
    case membersList
    /// Screen for adding a new member.
    case addMember
    case memberDetail(id: String)
}

// swiftlint:disable cyclomatic_complexity
extension View {
    /// Sets up routing destinations for various views, injecting necessary services.
    func withAppRouter(
        userService: UserService,
        clientService: ClientServiceProtocol,
        incidentService: IncidentServiceProtocol,
        memberService: MemberServiceProtocol
    ) -> some View {
        navigationDestination(for: RouterDestination.self) { destination in
            switch destination {
            case .signup:
                SignupWithNewTeamView(userService: userService)
            case .signupWithTeam:
                SignupWithExistingTeamView(userService: userService)
            case .clientsList:
                ClientsListView(service: clientService)
            case .addClient:
                AddClientView(service: clientService)
            case let .clientDetail(id):
                ClientDetailView(clientId: id, userService: userService)
            case .incidentsList:
                IncidentsListView(service: incidentService)
            case .addIncident:
                AddIncidentView(service: incidentService)
            case let .incidentDetail(id):
                IncidentDetailView(incidentId: id, userService: userService)
            case .membersList:
                MembersListView(service: memberService)
            case .addMember:
                AddMemberView(service: memberService)
            case let .memberDetail(id):
                MemberDetailView(memberId: id, userService: userService)
            }
        }
    }
}
// swiftlint:enable cyclomatic_complexity

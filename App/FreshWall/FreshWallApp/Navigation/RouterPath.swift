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
    case clientsList
    /// Screen for adding a new client.
    case addClient
    case clientDetail(client: Client)
    case incidentsList
    /// Screen for adding a new incident.
    case addIncident
    case incidentDetail(incident: Incident)
    case membersList
    /// Screen for adding a new member.
    case addMember
    case memberDetail(member: User)
}

// swiftlint:disable cyclomatic_complexity
extension View {
    /// Sets up routing destinations for various views, injecting necessary services.
    func withAppRouter(
        clientService: ClientServiceProtocol,
        incidentService: IncidentServiceProtocol,
        memberService: MemberServiceProtocol
    ) -> some View {
        navigationDestination(for: RouterDestination.self) { destination in
            switch destination {
            case .clientsList:
                ClientsListView(service: clientService)
            case .addClient:
                AddClientView(viewModel: AddClientViewModel(service: clientService))
            case let .clientDetail(client):
                ClientDetailView(client: client)
            case .incidentsList:
                IncidentsListView(service: incidentService)
            case .addIncident:
                AddIncidentView(viewModel: AddIncidentViewModel(service: incidentService))
            case let .incidentDetail(incident):
                IncidentDetailView(incident: incident)
            case .membersList:
                MembersListView(service: memberService)
            case .addMember:
                AddMemberView(viewModel: AddMemberViewModel(service: memberService))
            case let .memberDetail(member):
                MemberDetailView(member: member)
            }
        }
    }
}

// swiftlint:enable cyclomatic_complexity

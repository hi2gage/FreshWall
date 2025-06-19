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
    case clientDetail(client: ClientDTO)
    case incidentsList
    /// Screen for adding a new incident.
    case addIncident
    case incidentDetail(incident: IncidentDTO)
    case membersList
    /// Screen for adding a new member.
    case addMember
    case memberDetail(member: UserDTO)
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
                ClientsListView(
                    clientService: clientService,
                    incidentService: incidentService
                )
            case .addClient:
                AddClientView(viewModel: AddClientViewModel(service: clientService))
            case let .clientDetail(client):
                ClientDetailView(
                    client: client,
                    incidentService: incidentService,
                    clientService: clientService
                )
            case .incidentsList:
                IncidentsListView(
                    viewModel: IncidentsListViewModel(
                        incidentService: incidentService,
                        clientService: clientService
                    )
                )
            case .addIncident:
                AddIncidentView(
                    viewModel: AddIncidentViewModel(
                        service: incidentService,
                        clientService: clientService
                    )
                )
            case let .incidentDetail(incident):
                IncidentDetailView(
                    incident: incident,
                    incidentService: incidentService,
                    clientService: clientService
                )
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

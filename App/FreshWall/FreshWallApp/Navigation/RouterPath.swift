import SwiftData
import SwiftUI

// MARK: - RouterPath

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

// MARK: - RouterDestination

/// Destinations for navigation within the app.
enum RouterDestination: Hashable {
    case clientsList
    /// Screen for adding a new client.
    case addClient
    case clientDetail(client: Client)
    /// Screen for editing an existing client.
    case editClient(client: Client)
    case incidentsList
    /// Screen for adding a new incident.
    case addIncident
    case incidentDetail(incident: Incident)
    /// Screen for editing an existing incident.
    case editIncident(incident: Incident)
    case membersList
    /// Screen for adding a new member.
    case inviteMember
    case memberDetail(member: Member)
    /// Screen for viewing a photo in full screen.
    case photoViewer(context: PhotoViewerContext)
}

// swiftlint:disable cyclomatic_complexity
extension View {
    /// Sets up routing destinations for various views, injecting necessary services.
    func withAppRouter(
        clientService: ClientServiceProtocol,
        incidentService: IncidentServiceProtocol,
        memberService: MemberServiceProtocol,
        currentUserId: String
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
            case let .editClient(client):
                EditClientView(
                    viewModel: EditClientViewModel(client: client, service: clientService)
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
            case let .editIncident(incident):
                EditIncidentView(
                    viewModel: EditIncidentViewModel(
                        incident: incident,
                        incidentService: incidentService,
                        clientService: clientService
                    )
                )
            case .membersList:
                MembersListView(
                    service: memberService,
                    currentUserId: currentUserId
                )
            case .inviteMember:
                InviteMemberView(service: InviteCodeService())
            case let .memberDetail(member):
                MemberDetailView(member: member)
            case let .photoViewer(context):
                PhotoViewer(photos: context.photos, selectedPhoto: context.selectedPhoto)
            }
        }
    }
}

// swiftlint:enable cyclomatic_complexity

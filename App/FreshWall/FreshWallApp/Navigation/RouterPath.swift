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
    case addClient(onClientCreated: ((String) -> Void)? = nil)
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

    // MARK: - Hashable conformance

    static func == (lhs: RouterDestination, rhs: RouterDestination) -> Bool {
        switch (lhs, rhs) {
        case (.clientsList, .clientsList):
            true
        case (.addClient, .addClient):
            true
        case let (.clientDetail(lhsClient), .clientDetail(rhsClient)):
            lhsClient.id == rhsClient.id
        case let (.editClient(lhsClient), .editClient(rhsClient)):
            lhsClient.id == rhsClient.id
        case (.incidentsList, .incidentsList):
            true
        case (.addIncident, .addIncident):
            true
        case let (.incidentDetail(lhsIncident), .incidentDetail(rhsIncident)):
            lhsIncident.id == rhsIncident.id
        case let (.editIncident(lhsIncident), .editIncident(rhsIncident)):
            lhsIncident.id == rhsIncident.id
        case (.membersList, .membersList):
            true
        case (.inviteMember, .inviteMember):
            true
        case let (.memberDetail(lhsMember), .memberDetail(rhsMember)):
            lhsMember.id == rhsMember.id
        case let (.photoViewer(lhsContext), .photoViewer(rhsContext)):
            lhsContext.selectedPhoto == rhsContext.selectedPhoto
        default:
            false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .clientsList:
            hasher.combine("clientsList")
        case .addClient:
            hasher.combine("addClient")
        case let .clientDetail(client):
            hasher.combine("clientDetail")
            hasher.combine(client.id)
        case let .editClient(client):
            hasher.combine("editClient")
            hasher.combine(client.id)
        case .incidentsList:
            hasher.combine("incidentsList")
        case .addIncident:
            hasher.combine("addIncident")
        case let .incidentDetail(incident):
            hasher.combine("incidentDetail")
            hasher.combine(incident.id)
        case let .editIncident(incident):
            hasher.combine("editIncident")
            hasher.combine(incident.id)
        case .membersList:
            hasher.combine("membersList")
        case .inviteMember:
            hasher.combine("inviteMember")
        case let .memberDetail(member):
            hasher.combine("memberDetail")
            hasher.combine(member.id)
        case let .photoViewer(context):
            hasher.combine("photoViewer")
            hasher.combine(context.selectedPhoto)
        }
    }
}

// swiftlint:disable cyclomatic_complexity function_body_length
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
            case let .addClient(onClientCreated):
                AddClientView(
                    viewModel: AddClientViewModel(service: clientService),
                    onClientCreated: onClientCreated
                )
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

// swiftlint:enable cyclomatic_complexity function_body_length

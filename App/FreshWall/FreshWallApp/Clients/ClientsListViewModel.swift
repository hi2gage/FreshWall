import Foundation
import Observation

/// ViewModel responsible for client list presentation and data operations.
@MainActor
@Observable
final class ClientsListViewModel {
    /// Clients fetched from the client service.
    var clients: [Client] = []
    /// Incidents fetched from the incident service.
    var incidents: [Incident] = []

    var sort: SortState<ClientSortField> = .init(field: .incidentDate, isAscending: false)

    /// The current field used for sorting clients.
    var sortField: ClientSortField {
        get { sort.field }
        set { sort.field = newValue }
    }

    /// Indicates whether the sorting is in ascending order.
    var isAscending: Bool {
        get { sort.isAscending }
        set { sort.isAscending = newValue }
    }

    // The previous client sort option is now removed; fetching always returns unsorted list

    private let clientService: ClientServiceProtocol
    private let incidentService: IncidentServiceProtocol

    /// Initializes the view model with required services.
    init(clientService: ClientServiceProtocol, incidentService: IncidentServiceProtocol) {
        self.clientService = clientService
        self.incidentService = incidentService
    }

    /// Loads clients from the service.
    func loadClients() async {
        clients = await (try? clientService.fetchClients()) ?? []
    }

    /// Loads incidents from the service.
    func loadIncidents() async {
        incidents = await (try? incidentService.fetchIncidents()) ?? []
    }

    /// Returns clients sorted using the current sort field and direction.
    func sortedClients() -> [Client] {
        switch sortField {
        case .alphabetical:
            clients.sorted { lhs, rhs in
                if isAscending {
                    lhs.name < rhs.name
                } else {
                    lhs.name > rhs.name
                }
            }
        case .incidentDate:
            clients.sorted { lhs, rhs in
                let lhsDate = lastIncidentDate(for: lhs)
                let rhsDate = lastIncidentDate(for: rhs)
                if isAscending {
                    return lhsDate < rhsDate
                } else {
                    return lhsDate > rhsDate
                }
            }
        }
    }

    /// Returns the latest incident date for a client or distantPast if none.
    private func lastIncidentDate(for client: Client) -> Date {
        guard let id = client.id else { return .distantPast }

        let dates = incidents
            .filter { $0.clientRef?.documentID == id }
            .map { $0.createdAt.dateValue() }
        return dates.max() ?? .distantPast
    }
}

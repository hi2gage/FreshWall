@preconcurrency import FirebaseFirestore
import SwiftUI

/// A view displaying a list of incidents for the current team.
struct IncidentsListView: View {
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: IncidentsListViewModel

    /// Initializes the view with a configured `IncidentsListViewModel`.
    init(viewModel: IncidentsListViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        GenericGroupableListView(
            groups: viewModel.groupedIncidents(),
            title: "Incidents",
            groupOption: $viewModel.groupOption,
            sortField: $viewModel.sortField,
            isAscending: $viewModel.isAscending,
            destination: { incident in .incidentDetail(incident: incident) },
            content: { incident in
                IncidentListCell(incident: incident)
            },
            plusButtonAction: {
                routerPath.push(.addIncident)
            }
        )
        .task {
            await viewModel.loadIncidents()
            await viewModel.loadClients()
        }
    }
}

@MainActor
private class PreviewIncidentService: IncidentServiceProtocol {
    func fetchIncidents() async throws -> [IncidentDTO] { [] }
    func addIncident(_: IncidentDTO) async throws {}
    func addIncident(_: AddIncidentInput, beforeImages _: [Data], afterImages _: [Data]) async throws {}
    func updateIncident(_: String, with _: UpdateIncidentInput, beforeImages _: [Data], afterImages _: [Data]) async throws {}
}

@MainActor
private class PreviewClientService: ClientServiceProtocol {
    func fetchClients(sortedBy _: ClientSortOption) async throws -> [ClientDTO] {
        [ClientDTO(
            id: "client1",
            name: "Sample Client",
            notes: "Preview client",
            isDeleted: false,
            deletedAt: nil,
            createdAt: .init(),
            lastIncidentAt: .init()
        )]
    }

    func addClient(_: AddClientInput) async throws {}

    func updateClient(_: String, with _: UpdateClientInput) async throws {}
}

#Preview {
    let incidentService = PreviewIncidentService()
    let clientService = PreviewClientService()
    let viewModel = IncidentsListViewModel(
        incidentService: incidentService,
        clientService: clientService
    )
    FreshWallPreview {
        NavigationStack {
            IncidentsListView(viewModel: viewModel)
        }
    }
}

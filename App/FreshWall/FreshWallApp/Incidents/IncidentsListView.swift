@preconcurrency import FirebaseFirestore
import SwiftUI

/// A view displaying a list of incidents for the current team.
struct IncidentsListView: View {
    let incidentService: IncidentServiceProtocol
    let clientService: ClientServiceProtocol
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: IncidentsListViewModel
    @State private var clients: [ClientDTO] = []
    @State private var groupOption: IncidentGroupOption = .none
    @State private var showingGroupDialog = false

    /// Initializes the view with an incident service implementing `IncidentServiceProtocol`.
    init(incidentService: IncidentServiceProtocol, clientService: ClientServiceProtocol) {
        self.incidentService = incidentService
        self.clientService = clientService
        _viewModel = State(wrappedValue: IncidentsListViewModel(service: incidentService))
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.groupedIncidents(by: groupOption, clients: clients), id: \.title) { group in
                    if let title = group.title, groupOption != .none {
                        Text(title)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    ForEach(group.incidents) { incident in
                        NavigationLink(value: RouterDestination.incidentDetail(incident: incident)) {
                            IncidentListCell(incident: incident)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Incidents")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingGroupDialog = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    routerPath.push(.addIncident)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .confirmationDialog("Group By", isPresented: $showingGroupDialog) {
            ForEach(IncidentGroupOption.allCases, id: \.self) { option in
                Button(option.rawValue) { groupOption = option }
            }
        }
        .task {
            await viewModel.loadIncidents()
            clients = await (try? clientService.fetchClients(sortedBy: .createdAtAscending)) ?? []
        }
    }
}

#Preview {
    @MainActor class PreviewIncidentService: IncidentServiceProtocol {
        func fetchIncidents() async throws -> [IncidentDTO] { [] }
        func addIncident(_: IncidentDTO) async throws {}
        func addIncident(_ : AddIncidentInput, beforeImages _: [Data], afterImages _: [Data]) async throws {}
        func updateIncident(_ : String, with _: UpdateIncidentInput, beforeImages _: [Data], afterImages _: [Data]) async throws {}
    }

    @MainActor class PreviewClientService: ClientServiceProtocol {
        func fetchClients(sortedBy _: ClientSortOption) async throws -> [ClientDTO] {
            [ClientDTO(
                id: "client1",
                name: "Sample Client",
                notes: nil,
                isDeleted: false,
                deletedAt: nil,
                createdAt: .init(),
                lastIncidentAt: .init()
            )]
        }
        func addClient(_: AddClientInput) async throws {}
        func updateClient(_: String, with _: UpdateClientInput) async throws {}
    }

    let incidentService = PreviewIncidentService()
    let clientService = PreviewClientService()
    FreshWallPreview {
        NavigationStack {
            IncidentsListView(incidentService: incidentService, clientService: clientService)
        }
    }
}

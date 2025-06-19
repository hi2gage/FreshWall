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
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.groupedIncidents(), id: \.title) { group in
                    if let title = group.title, viewModel.groupOption != .none {
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
                    viewModel.showingGroupDialog = true
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
        .confirmationDialog("Group By", isPresented: $viewModel.showingGroupDialog) {
            ForEach(IncidentGroupOption.allCases, id: \.self) { option in
                Button(option.rawValue) { viewModel.groupOption = option }
            }
        }
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

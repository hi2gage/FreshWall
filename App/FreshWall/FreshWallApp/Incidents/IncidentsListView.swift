@preconcurrency import FirebaseFirestore
import SwiftUI

// MARK: - IncidentsListView

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
            routerDestination: { incident in .incidentDetail(incident: incident) },
            content: { incident in
                IncidentListCell(incident: incident)
            },
            plusButtonAction: viewModel.permissions.canCreateIncidents ? {
                routerPath.push(.addIncident)
            } : {},
            refreshAction: {
                await viewModel.loadIncidents()
                await viewModel.loadClients()
            },
            menu: { collapsedGroups in
                Menu {
                    groupingMenu(groups: viewModel.groupedIncidents(), collapsedGroups: collapsedGroups)
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        )
        .task {
            await viewModel.loadIncidents()
            await viewModel.loadClients()
        }
    }

    @ViewBuilder
    private func groupingMenu(
        groups: [(title: String?, items: [Incident])],
        collapsedGroups: Binding<Set<Int>>
    ) -> some View {
        Text("Group By")
            .font(.caption)
            .foregroundColor(.secondary)

        Picker("Group By", selection: $viewModel.groupOption) {
            Text("None").tag(IncidentGroupOption?.none)
            ForEach(IncidentGroupOption.allCases, id: \.self) { option in
                Text(option.rawValue).tag(Optional.some(option))
            }
        }

        Text("Sort By")
            .font(.caption)
            .foregroundColor(.secondary)

        if viewModel.groupOption == nil {
            SortButton(for: .alphabetical, sort: $viewModel.sort)
            SortButton(for: .date, sort: $viewModel.sort)
        } else {
            SortButton(for: .date, sort: $viewModel.sort)
            collapseToggleButton(groups: groups, collapsedGroups: collapsedGroups)
        }

        // Enhanced filtering options using dropdowns
        Divider()

        Text("Filter By")
            .font(.caption)
            .foregroundColor(.secondary)

        // Status Filter
        Picker("Status", selection: $viewModel.statusFilter) {
            Text("All Statuses").tag(IncidentStatus?.none)
            ForEach(IncidentStatus.allCases, id: \.self) { status in
                Text(status.displayName).tag(Optional.some(status))
            }
        }

        // Surface Type Filter
        Picker("Surface Type", selection: $viewModel.surfaceTypeFilter) {
            Text("All Surface Types").tag(SurfaceType?.none)
            ForEach(SurfaceType.allCases, id: \.self) { surface in
                Text(surface.displayName).tag(Optional.some(surface))
            }
        }

        // Client Filter
        if !viewModel.clients.isEmpty {
            Picker("Client", selection: $viewModel.clientFilter) {
                Text("All Clients").tag(String?.none)
                ForEach(viewModel.clients, id: \.id) { client in
                    Text(client.name).tag(Optional.some(client.id))
                }
            }
        }

        // Clear Filters
        if viewModel.hasActiveFilters {
            Button("Clear All Filters") {
                viewModel.clearFilters()
            }
        }
    }

    @ViewBuilder
    private func collapseToggleButton(
        groups: [(title: String?, items: [Incident])],
        collapsedGroups: Binding<Set<Int>>
    ) -> some View {
        let allCollapsed = collapsedGroups.wrappedValue.count == groups.count

        Button {
            if allCollapsed {
                collapsedGroups.wrappedValue.removeAll()
            } else {
                collapsedGroups.wrappedValue = Set(groups.indices)
            }
        } label: {
            Label(
                allCollapsed ? "Uncollapse All" : "Collapse All",
                systemImage: allCollapsed ? "chevron.down" : "chevron.right"
            )
        }
    }
}

// MARK: - PreviewIncidentService

@MainActor
private class PreviewIncidentService: IncidentServiceProtocol {
    func deleteIncident(_: String) async throws {}

    func fetchIncidents() async throws -> [Incident] { [] }
    func addIncident(_: Incident) async throws {}
    func addIncident(_: AddIncidentInput, beforePhotos _: [PickedPhoto], afterPhotos _: [PickedPhoto]) async throws -> String { "preview-incident-id" }
    func updateIncident(
        _: String,
        with _: UpdateIncidentInput,
        beforePhotos _: [PickedPhoto],
        afterPhotos _: [PickedPhoto]
    ) async throws {}
}

// MARK: - PreviewClientService

@MainActor
private class PreviewClientService: ClientServiceProtocol {
    func deleteClient(_: String) async throws {}

    func fetchClients() async throws -> [Client] {
        [Client(
            id: "client1",
            name: "Sample Client",
            notes: "Preview client",
            isDeleted: false,
            deletedAt: nil,
            createdAt: .init(),
            lastIncidentAt: .init()
        )]
    }

    func addClient(_: AddClientInput) async throws -> String { "mock-id" }

    func updateClient(_: String, with _: UpdateClientInput) async throws {}
}

#Preview {
    let incidentService = PreviewIncidentService()
    let clientService = PreviewClientService()
    let viewModel = IncidentsListViewModel(
        incidentService: incidentService,
        clientService: clientService,
        userSession: UserSession(
            userId: "preview",
            displayName: "Preview User",
            teamId: "preview-team",
            role: .admin
        )
    )
    FreshWallPreview {
        NavigationStack {
            IncidentsListView(viewModel: viewModel)
        }
    }
}

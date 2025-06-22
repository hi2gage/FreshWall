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
        groups: [(title: String?, items: [IncidentDTO])],
        collapsedGroups: Binding<Set<Int>>
    ) -> some View {
        Text("Group By")
            .font(.caption)
            .foregroundColor(.secondary)

        Picker("Group By", selection: $viewModel.groupOption) {
            Text("None").tag(Optional<IncidentGroupOption>.none)
            ForEach(Array(IncidentGroupOption.allCases), id: \\.self) { option in
                Text(option.rawValue).tag(Optional.some(option))
            }
        }

        Text("Order By")
            .font(.caption)
            .foregroundColor(.secondary)

        if viewModel.groupOption == nil {
            Button {
                if viewModel.sortField == .alphabetical {
                    viewModel.isAscending.toggle()
                } else {
                    viewModel.sortField = .alphabetical
                    viewModel.isAscending = true
                }
            } label: {
                let arrow = viewModel.sortField == .alphabetical ? (viewModel.isAscending ? "arrow.up" : "arrow.down") : ""
                Label("Alphabetical", systemImage: arrow)
            }

            Button {
                if viewModel.sortField == .date {
                    viewModel.isAscending.toggle()
                } else {
                    viewModel.sortField = .date
                    viewModel.isAscending = true
                }
            } label: {
                let arrow = viewModel.sortField == .date ? (viewModel.isAscending ? "arrow.up" : "arrow.down") : ""
                Label("By Date", systemImage: arrow)
            }
        } else {
            Button {
                viewModel.isAscending.toggle()
            } label: {
                let arrow = viewModel.sortField == .date ? (viewModel.isAscending ? "arrow.up" : "arrow.down") : ""
                Label("Order", systemImage: arrow)
            }

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

@preconcurrency import FirebaseFirestore
import SwiftUI

// MARK: - IncidentsListView

/// A view displaying a list of incidents for the current team.
struct IncidentsListView: View {
    @Environment(RouterPath.self) private var routerPath
    @State private var viewModel: IncidentsListViewModel
    @State private var showCustomDateAlert = false

    /// Initializes the view with a configured `IncidentsListViewModel`.
    init(viewModel: IncidentsListViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        GenericGroupableListView(
            groups: viewModel.groupedIncidents(),
            title: "Incidents",
            groupOption: $viewModel.groupOption,
            routerDestination: { incident in .incidentDetail(incident: incident)
            },
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
                HStack {
                    Menu {
                        dateRangeMenu()
                    } label: {
                        Image(systemName: "calendar")
                    }

                    Menu {
                        groupingMenu(
                            groups: viewModel.groupedIncidents(),
                            collapsedGroups: collapsedGroups
                        )
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        )
        .task {
            await viewModel.loadIncidents()
            await viewModel.loadClients()
        }
        .alert("Custom Date Range", isPresented: $showCustomDateAlert) {
            Button("OK") {}
        } message: {
            Text("Not finished yet, coming soon!")
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
    private func dateRangeMenu() -> some View {
        Text("Date Range")
            .font(.caption)
            .foregroundColor(.secondary)

        Picker("Date Range", selection: $viewModel.dateRangeFilter) {
            Text("All Dates").tag(DateRangeOption?.none)
            ForEach(DateRangeOption.allCases, id: \.self) { range in
                Text(range.displayName).tag(Optional.some(range))
            }
        }
        .onChange(of: viewModel.dateRangeFilter) { _, newValue in
            if newValue == .custom {
                showCustomDateAlert = true
                viewModel.dateRangeFilter = nil
            }
        }

        if viewModel.dateRangeFilter != nil {
            Button("Clear Date Filter") {
                viewModel.dateRangeFilter = nil
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

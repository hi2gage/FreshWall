import Foundation
import Observation

// MARK: - DateRangeOption

enum DateRangeOption: String, CaseIterable, Codable, Sendable {
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case thisYear = "This Year"
    case custom = "Custom"

    var displayName: String { rawValue }
}

// MARK: - IncidentsListViewModel

/// ViewModel responsible for incident list presentation and data operations.
@MainActor
@Observable
final class IncidentsListViewModel {
    /// Incidents fetched from the service.
    var incidents: [Incident] = []
    /// Clients used for grouping by client name.
    var clients: [Client] = []

    /// Flag to prevent didSet during initialization
    private var isInitializing = true

    /// Selected grouping option for incidents - cached locally, synced with FilterManager
    var groupOption: IncidentGroupOption? {
        didSet {
            guard !isInitializing else { return }

            FilterManager.incidentsGroupOption = groupOption
        }
    }

    /// Client filter - cached locally, synced with FilterManager
    var clientFilter: String? {
        didSet {
            guard !isInitializing else { return }

            FilterManager.incidentsClientFilter = clientFilter
        }
    }

    /// Date range filter - cached locally, synced with FilterManager
    var dateRangeFilter: DateRangeOption? {
        didSet {
            guard !isInitializing else { return }

            FilterManager.incidentsDateRangeFilter = dateRangeFilter
        }
    }

    /// The field by which incidents are currently sorted.
    var sortField: IncidentSortField {
        get { sort.field }
        set { sort.field = newValue }
    }

    /// Indicates whether the incident sorting is ascending.
    var isAscending: Bool {
        get { sort.isAscending }
        set { sort.isAscending = newValue }
    }

    var sort: SortState<IncidentSortField> = .init(field: .date, isAscending: true) {
        didSet {
            guard !isInitializing else { return }

            FilterManager.incidentsSort = sort
        }
    }

    private let service: IncidentServiceProtocol
    private let clientService: ClientServiceProtocol
    private let userSession: UserSession

    /// Permission checker for role-based functionality
    var permissions: PermissionChecker {
        PermissionChecker(userRole: userSession.role)
    }

    /// Initializes the view model with a service conforming to `IncidentServiceProtocol`.
    init(
        incidentService: IncidentServiceProtocol,
        clientService: ClientServiceProtocol,
        userSession: UserSession
    ) {
        service = incidentService
        self.clientService = clientService
        self.userSession = userSession

        // Load cached filter preferences from FilterManager
        loadCachedFilters()

        // Enable storage sync after initialization
        isInitializing = false
    }

    /// Loads previously saved filter preferences from FilterManager
    private func loadCachedFilters() {
        // Load filters while isInitializing=true prevents didSet from writing to storage
        groupOption = FilterManager.incidentsGroupOption
        clientFilter = FilterManager.incidentsClientFilter
        dateRangeFilter = FilterManager.incidentsDateRangeFilter
        sort = FilterManager.incidentsSort
    }

    /// Loads incidents from the service.
    func loadIncidents() async {
        incidents = await (try? service.fetchIncidents()) ?? []
    }

    /// Computed property for filtered incidents based on dropdown filters
    private var filteredIncidents: [Incident] {
        var filtered = incidents

        // Apply client filter
        if let clientFilter {
            filtered = filtered.filter { $0.clientRef?.documentID == clientFilter }
        }

        // Apply date range filter
        if let dateRangeFilter {
            let calendar = Calendar.current
            let now = Date()

            let dateRange: (start: Date, end: Date)? = {
                switch dateRangeFilter {
                case .today:
                    let startOfDay = calendar.startOfDay(for: now)
                    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? now
                    return (startOfDay, endOfDay)
                case .thisWeek:
                    guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start,
                          let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end else { return nil }

                    return (startOfWeek, endOfWeek)
                case .thisMonth:
                    guard let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start,
                          let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end else { return nil }

                    return (startOfMonth, endOfMonth)
                case .thisYear:
                    guard let startOfYear = calendar.dateInterval(of: .year, for: now)?.start,
                          let endOfYear = calendar.dateInterval(of: .year, for: now)?.end else { return nil }

                    return (startOfYear, endOfYear)
                case .custom:
                    // Custom range not implemented yet
                    return nil
                }
            }()

            if let dateRange {
                filtered = filtered.filter { incident in
                    let incidentDate = incident.startTime.dateValue()
                    return incidentDate >= dateRange.start && incidentDate < dateRange.end
                }
            }
        }

        // Apply role-based filtering for field workers
        if userSession.role == .fieldWorker {
            filtered = filtered.filter { incident in
                incident.createdBy.documentID == userSession.userId
                // TODO: Also check assigned workers when that field is added
            }
        }

        return filtered
    }

    /// Whether any filters are currently active
    var hasActiveFilters: Bool {
        clientFilter != nil || dateRangeFilter != nil
    }

    /// Clears all active filters
    func clearFilters() {
        clientFilter = nil
        dateRangeFilter = nil
        // This will automatically sync to FilterManager via didSet
    }

    /// Returns incidents grouped according to the provided option and clients.
    /// - Parameters:
    ///   - option: How incidents should be grouped.
    ///   - clients: All clients used to resolve names when grouping by client.
    /// - Returns: An array of tuples where the first value is an optional group
    ///   title and the second is the incidents for that group.
    func loadClients() async {
        clients = await (try? clientService.fetchClients()) ?? []
    }

    func groupedIncidents() -> [(title: String?, items: [Incident])] {
        switch groupOption {
        case .none:
            let sorted = sort(filteredIncidents)
            return [(nil, sorted)]
        case .client:
            let groups = Dictionary(grouping: filteredIncidents) { incident in
                incident.clientRef?.documentID
            }
            return groups
                .map { key, value in
                    let name = clients.first { $0.id == key }?.name ?? "No Client"
                    return (title: name, items: sort(value))
                }
                .sorted { lhs, rhs in
                    let lhsName = lhs.title ?? ""
                    let rhsName = rhs.title ?? ""
                    return isAscending ? lhsName < rhsName : lhsName > rhsName
                }
        case .date:
            let dayGroups = Dictionary(grouping: filteredIncidents) { incident in
                Calendar.current.startOfDay(for: incident.startTime.dateValue())
            }
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return dayGroups
                .map { date, value in
                    (
                        title: formatter.string(from: date),
                        items: sort(value)
                    )
                }
                .sorted { lhs, rhs in
                    guard
                        let lhsDate = formatter.date(from: lhs.title ?? ""),
                        let rhsDate = formatter.date(from: rhs.title ?? "") else { return false }

                    return isAscending ? lhsDate < rhsDate : lhsDate > rhsDate
                }
        }
    }

    /// Sorts incidents using the current sort field and direction.
    private func sort(_ items: [Incident]) -> [Incident] {
        switch sortField {
        case .alphabetical:
            items.sorted { lhs, rhs in
                let lhsDesc = lhs.description
                let rhsDesc = rhs.description
                if isAscending {
                    return lhsDesc < rhsDesc
                } else {
                    return lhsDesc > rhsDesc
                }
            }
        case .date:
            items.sorted { lhs, rhs in
                let lhsDate = lhs.startTime.dateValue()
                let rhsDate = rhs.startTime.dateValue()
                if isAscending {
                    return lhsDate < rhsDate
                } else {
                    return lhsDate > rhsDate
                }
            }
        }
    }
}

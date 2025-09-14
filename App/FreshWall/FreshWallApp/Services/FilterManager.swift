import Foundation
import TinyStorage

// MARK: - FilterStorageKeys

enum FilterStorageKeys: String, TinyStorageKey {
    case incidentsDateRange = "incidents_date_range_filter"
    case incidentsClient = "incidents_client_filter"
    case incidentsGroupOption = "incidents_group_option"
    case incidentsSort = "incidents_sort"
}

// MARK: - FilterManager

/// Manages filter persistence for various list views using TinyStorage
@MainActor
final class FilterManager {
    // MARK: - Static Defaults

    /// Default values for incidents filters
    enum IncidentsDefaults {
        static let dateRangeFilter: DateRangeOption? = nil
        static let clientFilter: String? = nil
        static let groupOption: IncidentGroupOption? = nil
        static let sort: SortState<IncidentSortField> = .init(field: .date, isAscending: false)
    }

    // MARK: - TinyStorage Instance

    private static let storage: TinyStorage = {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return .init(insideDirectory: documentsURL, name: "filter-preferences")
    }()

    // MARK: - Incidents Filters

    /// Current date range filter for incidents
    static var incidentsDateRangeFilter: DateRangeOption? {
        get {
            storage.retrieve(
                type: DateRangeOption.self,
                forKey: FilterStorageKeys.incidentsDateRange
            ) ?? IncidentsDefaults.dateRangeFilter
        }
        set {
            if let newValue {
                storage.store(newValue, forKey: FilterStorageKeys.incidentsDateRange)
            } else {
                storage.remove(key: FilterStorageKeys.incidentsDateRange)
            }
        }
    }

    /// Current client filter for incidents
    static var incidentsClientFilter: String? {
        get {
            storage.retrieve(
                type: String.self,
                forKey: FilterStorageKeys.incidentsClient
            ) ?? IncidentsDefaults.clientFilter
        }
        set {
            if let newValue {
                storage.store(newValue, forKey: FilterStorageKeys.incidentsClient)
            } else {
                storage.remove(key: FilterStorageKeys.incidentsClient)
            }
        }
    }

    /// Current group option for incidents
    static var incidentsGroupOption: IncidentGroupOption? {
        get {
            storage.retrieve(
                type: IncidentGroupOption.self,
                forKey: FilterStorageKeys.incidentsGroupOption
            ) ?? IncidentsDefaults.groupOption
        }
        set {
            if let newValue {
                storage.store(newValue, forKey: FilterStorageKeys.incidentsGroupOption)
            } else {
                storage.remove(key: FilterStorageKeys.incidentsGroupOption)
            }
        }
    }

    /// Current sort state for incidents
    static var incidentsSort: SortState<IncidentSortField> {
        get {
            storage.retrieve(
                type: SortState<IncidentSortField>.self,
                forKey: FilterStorageKeys.incidentsSort
            ) ?? IncidentsDefaults.sort
        }
        set {
            storage.store(newValue, forKey: FilterStorageKeys.incidentsSort)
        }
    }

    // MARK: - Clear Methods

    /// Clears all stored incidents filters
    static func clearIncidentsFilters() {
        incidentsDateRangeFilter = nil
        incidentsClientFilter = nil
        // Note: We don't clear group option and sort as these are more like preferences
    }

    /// Clears all stored filter preferences (including grouping and sorting)
    static func clearAllIncidentsPreferences() {
        incidentsDateRangeFilter = nil
        incidentsClientFilter = nil
        incidentsGroupOption = nil
        incidentsSort = .init(field: .date, isAscending: false)
    }
}

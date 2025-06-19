import Foundation

/// Options for grouping incidents in the list view.
enum IncidentGroupOption: String, CaseIterable {
    /// Group incidents by their associated client.
    case client = "Client"
    /// Group incidents by the start date of the incident.
    case date = "Date"
}

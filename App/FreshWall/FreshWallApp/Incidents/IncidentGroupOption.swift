import Foundation

/// Options for grouping incidents in the list view.
enum IncidentGroupOption: String, CaseIterable {
    /// No grouping, show incidents in a flat list.
    case none = "None"
    /// Group incidents by their associated client.
    case client = "Client"
}

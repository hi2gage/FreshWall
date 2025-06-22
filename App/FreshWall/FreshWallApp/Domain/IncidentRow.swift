import FirebaseFirestore
import Foundation

/// Domain model representing an incident for UI display.
struct IncidentRow: Identifiable, Hashable {
    let id: String
    let description: String
    let status: String
    let startDate: Date
}

extension IncidentRow {
    /// Generates domain rows from Firestore incidents, filtering out those without IDs.
    static func makeRows(from incidents: [Incident]) -> [IncidentRow] {
        incidents.compactMap { incident in
            guard let id = incident.id else { return nil }
            return IncidentRow(
                id: id,
                description: incident.description,
                status: incident.status.capitalized,
                startDate: incident.startTime.dateValue()
            )
        }
    }
}

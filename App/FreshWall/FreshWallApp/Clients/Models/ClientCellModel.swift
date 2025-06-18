import FirebaseFirestore
import Foundation

/// Domain model representing a client for UI display.
struct ClientCellModel: Identifiable, Hashable {
    let id: String
    let name: String
    let notes: String?
    let isDeleted: Bool
    let createdAt: Date
    let lastIncidentDate: Date
}

extension ClientCellModel {
    /// Generates domain rows from Firestore clients and incidents, filtering out those without IDs.
    static func makeRows(from clients: [ClientDTO], incidents: [IncidentDTO]) -> [ClientCellModel] {
        clients.compactMap { client in
            guard let id = client.id else { return nil }
            let lastDate = incidents
                .filter { $0.clientRef.documentID == id }
                .map { $0.createdAt.dateValue() }
                .max() ?? Date.distantPast
            return ClientCellModel(
                id: id,
                name: client.name,
                notes: client.notes,
                isDeleted: client.isDeleted,
                createdAt: client.createdAt.dateValue(),
                lastIncidentDate: lastDate
            )
        }
        .sorted { $0.lastIncidentDate > $1.lastIncidentDate }
    }
}

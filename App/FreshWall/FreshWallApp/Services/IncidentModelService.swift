import FirebaseAuth
@preconcurrency import FirebaseFirestore
import Foundation

/// Handles Firestore reads and writes for incidents.
protocol IncidentModelServiceProtocol: Sendable {
    func fetchIncidents(teamId: String) async throws -> [IncidentDTO]
    func setIncident(_ incident: IncidentDTO, at ref: DocumentReference) async throws
    func newIncidentDocument(teamId: String) -> DocumentReference
    func updateIncident(id: String, teamId: String, data: [String: Any]) async throws
}

struct IncidentModelService: IncidentModelServiceProtocol {
    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func fetchIncidents(teamId: String) async throws -> [IncidentDTO] {
        let snapshot = try await firestore
            .collection("teams")
            .document(teamId)
            .collection("incidents")
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: IncidentDTO.self) }
    }

    func newIncidentDocument(teamId: String) -> DocumentReference {
        firestore
            .collection("teams")
            .document(teamId)
            .collection("incidents")
            .document()
    }

    func setIncident(_ incident: IncidentDTO, at ref: DocumentReference) async throws {
        try await ref.setData(from: incident)
    }

    func updateIncident(id: String, teamId: String, data: [String: Any]) async throws {
        let ref = firestore
            .collection("teams")
            .document(teamId)
            .collection("incidents")
            .document(id)
        try await ref.updateData(data)
    }
}

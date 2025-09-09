@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - IncidentModelServiceProtocol

/// Handles Firestore reads and writes for ``IncidentDTO`` models.
///
/// Similar to ``ClientModelServiceProtocol`` this protocol isolates the
/// low-level Firestore interactions from higher level services.
protocol IncidentModelServiceProtocol: Sendable {
    /// Fetch all incidents for the given team.
    func fetchIncidents(teamId: String) async throws -> [IncidentDTO]

    /// Returns a new document reference for an incident.
    func newIncidentDocument(teamId: String) -> DocumentReference

    /// Writes an ``IncidentDTO`` to a new document reference.
    func setIncident(_ incident: IncidentDTO, at ref: DocumentReference) async throws

    /// Apply the provided data updates to an existing incident document.
    func updateIncident(id: String, teamId: String, data: [String: Any]) async throws

    /// Deletes an existing incident document.
    func deleteIncident(id: String, teamId: String) async throws
}

// MARK: - IncidentModelService

/// ``IncidentModelServiceProtocol`` implementation backed by ``Firestore``.
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

    func deleteIncident(id: String, teamId: String) async throws {
        let ref = firestore
            .collection("teams")
            .document(teamId)
            .collection("incidents")
            .document(id)
        try await ref.delete()
    }
}

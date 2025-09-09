@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - ClientModelServiceProtocol

/// Handles Firestore reads and writes for `ClientDTO` models.
///
/// This service is intentionally low level and used by higher level client
/// services to isolate Firestore calls.
protocol ClientModelServiceProtocol: Sendable {
    /// Fetch all non-deleted clients for the given team.
    func fetchClients(teamId: String) async throws -> [ClientDTO]

    /// Returns a new document reference for a client under the given team.
    func newClientDocument(teamId: String) -> DocumentReference

    /// Writes a `ClientDTO` to the provided document reference.
    func setClient(_ client: ClientDTO, at ref: DocumentReference) async throws

    /// Updates an existing client document with the supplied data.
    func updateClient(id: String, teamId: String, data: [String: Any]) async throws

    /// Deletes an existing client document.
    func deleteClient(id: String, teamId: String) async throws

    /// Returns a reference to a specific client document.
    func clientDocument(teamId: String, clientId: String) -> DocumentReference
}

// MARK: - ClientModelService

/// Concrete implementation of ``ClientModelServiceProtocol`` backed by
/// ``Firestore``.
struct ClientModelService: ClientModelServiceProtocol {
    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func fetchClients(teamId: String) async throws -> [ClientDTO] {
        let snapshot = try await firestore
            .collection("teams")
            .document(teamId)
            .collection("clients")
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: ClientDTO.self) }
    }

    func newClientDocument(teamId: String) -> DocumentReference {
        firestore
            .collection("teams")
            .document(teamId)
            .collection("clients")
            .document()
    }

    func setClient(_ client: ClientDTO, at ref: DocumentReference) async throws {
        try await ref.setData(from: client)
    }

    func updateClient(id: String, teamId: String, data: [String: Any]) async throws {
        let ref = firestore
            .collection("teams")
            .document(teamId)
            .collection("clients")
            .document(id)
        try await ref.updateData(data)
    }

    func deleteClient(id: String, teamId: String) async throws {
        let ref = firestore
            .collection("teams")
            .document(teamId)
            .collection("clients")
            .document(id)
        try await ref.delete()
    }

    func clientDocument(teamId: String, clientId: String) -> DocumentReference {
        firestore
            .collection("teams")
            .document(teamId)
            .collection("clients")
            .document(clientId)
    }
}

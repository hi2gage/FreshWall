@preconcurrency import FirebaseFirestore
import Foundation

/// Handles Firestore reads and writes for clients.
protocol ClientModelServiceProtocol: Sendable {
    func fetchClients(teamId: String, sortedBy sortOption: ClientSortOption) async throws -> [ClientDTO]
    func newClientDocument(teamId: String) -> DocumentReference
    func setClient(_ client: ClientDTO, at ref: DocumentReference) async throws
    func updateClient(id: String, teamId: String, data: [String: Any]) async throws
    func clientDocument(teamId: String, clientId: String) -> DocumentReference
}

struct ClientModelService: ClientModelServiceProtocol {
    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func fetchClients(teamId: String, sortedBy sortOption: ClientSortOption) async throws -> [ClientDTO] {
        let snapshot = try await firestore
            .collection("teams")
            .document(teamId)
            .collection("clients")
            .order(by: sortOption.field, descending: sortOption.isDescending)
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

    func clientDocument(teamId: String, clientId: String) -> DocumentReference {
        firestore
            .collection("teams")
            .document(teamId)
            .collection("clients")
            .document(clientId)
    }
}

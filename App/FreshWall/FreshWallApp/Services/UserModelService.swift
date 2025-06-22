@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - UserModelServiceProtocol

/// Provides helpers for working with Firestore user documents.
///
/// Primarily used by ``IncidentService`` when resolving `createdBy` or
/// `lastModifiedBy` references.
protocol UserModelServiceProtocol: Sendable {
    /// Returns a reference to a user document within the given team.
    func userDocument(teamId: String, userId: String) -> DocumentReference
}

// MARK: - UserModelService

/// ``UserModelServiceProtocol`` implementation backed by ``Firestore``.
struct UserModelService: UserModelServiceProtocol {
    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func userDocument(teamId: String, userId: String) -> DocumentReference {
        firestore
            .collection("teams")
            .document(teamId)
            .collection("users")
            .document(userId)
    }
}

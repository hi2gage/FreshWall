@preconcurrency import FirebaseFirestore
import Foundation

/// Provides helpers for working with Firestore user documents.
protocol UserModelServiceProtocol: Sendable {
    func userDocument(teamId: String, userId: String) -> DocumentReference
}

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

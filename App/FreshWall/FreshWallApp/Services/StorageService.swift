@preconcurrency import FirebaseStorage
import Foundation

/// Protocol defining operations for uploading binary data to Firebase Storage.
protocol StorageServiceProtocol: Sendable {
    /// Uploads data to the given storage path and returns a download URL string.
    func uploadData(_ data: Data, to path: String) async throws -> String
}

/// Concrete storage service using `FirebaseStorage`.
struct StorageService: StorageServiceProtocol {
    private let storage: Storage

    init(storage: Storage = .storage()) {
        self.storage = storage
    }

    func uploadData(_ data: Data, to path: String) async throws -> String {
        let ref = storage.reference(withPath: path)
        _ = try await withCheckedThrowingContinuation { continuation in
            ref.putData(data, metadata: nil) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
        return try await ref.downloadURL().absoluteString
    }
}

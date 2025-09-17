@preconcurrency import FirebaseStorage
import Foundation

// MARK: - StorageServiceProtocol

/// Protocol defining operations for uploading binary data to Firebase Storage.
protocol StorageServiceProtocol: Sendable {
    /// Uploads data to the given storage path and returns a download URL string.
    func uploadData(_ data: Data, to path: String) async throws -> String
}

// MARK: - StorageService

/// Concrete storage service using `FirebaseStorage`.
struct StorageService: StorageServiceProtocol {
    private let storage: Storage

    init() {
        self.storage = Storage.storage()
    }

    func uploadData(_ data: Data, to path: String) async throws -> String {
        let ref = storage.reference(withPath: path)

        // Create metadata with proper Content-Type for images
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        // Upload data with progress reporting
        let _ = try await ref.putDataAsync(data, metadata: metadata)

        // Get download URL
        return try await withCheckedThrowingContinuation { continuation in
            ref.downloadURL { url, error in
                if let url {
                    continuation.resume(returning: url.absoluteString)
                } else {
                    continuation.resume(throwing: error ?? NSError(
                        domain: "StorageService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to fetch download URL"]
                    ))
                }
            }
        }
    }
}

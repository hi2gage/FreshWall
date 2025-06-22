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
        #if DEBUG
            let storage = Storage.storage()
            // Connect to the emulator
            storage.useEmulator(withHost: "localhost", port: 9199)
            self.storage = storage
        #else
            self.storage = Storage.storage()
        #endif
    }

    func uploadData(_ data: Data, to path: String) async throws -> String {
        let ref = storage.reference(withPath: path)

        // Upload data with progress reporting
        let metadata = try await ref.putDataAsync(data)

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

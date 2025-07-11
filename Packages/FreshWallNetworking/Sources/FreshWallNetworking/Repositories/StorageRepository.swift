import Foundation

public protocol StorageRepository {
    func uploadImage(data: Data, path: String) async throws -> URL
    func deleteImage(at url: URL) async throws
}

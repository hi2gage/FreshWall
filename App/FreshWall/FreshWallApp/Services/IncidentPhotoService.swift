import Foundation

/// Handles Firebase Storage uploads for incident photos.
///
/// The protocol is separate from ``IncidentServiceProtocol`` so that photo
/// management can be mocked independently in tests.
protocol IncidentPhotoServiceProtocol: Sendable {
    /// Uploads the given images as "before" photos and returns their download
    /// URLs.
    func uploadBeforePhotos(teamId: String, incidentId: String, images: [Data]) async throws -> [String]

    /// Uploads the given images as "after" photos and returns their download
    /// URLs.
    func uploadAfterPhotos(teamId: String, incidentId: String, images: [Data]) async throws -> [String]
}

/// Default ``IncidentPhotoServiceProtocol`` implementation using
/// ``StorageService``.
struct IncidentPhotoService: IncidentPhotoServiceProtocol {
    private let storage: StorageServiceProtocol

    init(storage: StorageServiceProtocol = StorageService()) {
        self.storage = storage
    }

    func uploadBeforePhotos(teamId: String, incidentId: String, images: [Data]) async throws -> [String] {
        try await upload(images: images, teamId: teamId, incidentId: incidentId, folder: "before")
    }

    func uploadAfterPhotos(teamId: String, incidentId: String, images: [Data]) async throws -> [String] {
        try await upload(images: images, teamId: teamId, incidentId: incidentId, folder: "after")
    }

    private func upload(images: [Data], teamId: String, incidentId: String, folder: String) async throws -> [String] {
        var urls: [String] = []
        for data in images {
            let path = "teams/\(teamId)/incidents/\(incidentId)/\(folder)/\(UUID().uuidString).jpg"
            let url = try await storage.uploadData(data, to: path)
            urls.append(url)
        }
        return urls
    }
}

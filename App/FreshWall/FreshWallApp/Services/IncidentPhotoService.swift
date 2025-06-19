import Foundation

/// Handles Storage uploads for incident photos.
protocol IncidentPhotoServiceProtocol: Sendable {
    func uploadBeforePhotos(teamId: String, incidentId: String, images: [Data]) async throws -> [String]
    func uploadAfterPhotos(teamId: String, incidentId: String, images: [Data]) async throws -> [String]
}

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

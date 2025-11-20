import UIKit

/// In-memory cache for storing temporary UIImages during photo upload
/// Photos are stored by incident ID and cleared once uploaded to Firebase Storage
@MainActor
final class LocalPhotoCache {
    static let shared = LocalPhotoCache()

    /// Storage for temporary photos keyed by incident ID
    /// Value is a tuple of (beforePhotos, afterPhotos)
    private var cache: [String: (before: [UIImage], after: [UIImage])] = [:]

    private init() {}

    /// Store temporary photos for an incident
    /// - Parameters:
    ///   - incidentId: The incident ID
    ///   - beforePhotos: Array of before photos to cache
    ///   - afterPhotos: Array of after photos to cache
    func storePhotos(
        for incidentId: String,
        beforePhotos: [UIImage],
        afterPhotos: [UIImage]
    ) {
        print("📸 LocalPhotoCache: Storing \(beforePhotos.count) before + \(afterPhotos.count) after photos for incident \(incidentId)")
        cache[incidentId] = (before: beforePhotos, after: afterPhotos)
    }

    /// Get the first thumbnail for an incident (before or after)
    /// - Parameter incidentId: The incident ID
    /// - Returns: The first available photo (before photo takes priority), or nil if none cached
    func getThumbnail(for incidentId: String) -> UIImage? {
        guard let photos = cache[incidentId] else { return nil }

        return photos.before.first ?? photos.after.first
    }

    /// Get all before photos for an incident
    /// - Parameter incidentId: The incident ID
    /// - Returns: Array of before photos, empty if none cached
    func getBeforePhotos(for incidentId: String) -> [UIImage] {
        cache[incidentId]?.before ?? []
    }

    /// Get all after photos for an incident
    /// - Parameter incidentId: The incident ID
    /// - Returns: Array of after photos, empty if none cached
    func getAfterPhotos(for incidentId: String) -> [UIImage] {
        cache[incidentId]?.after ?? []
    }

    /// Check if incident has any cached photos
    /// - Parameter incidentId: The incident ID
    /// - Returns: True if incident has cached photos
    func hasPhotos(for incidentId: String) -> Bool {
        guard let photos = cache[incidentId] else { return false }

        return !photos.before.isEmpty || !photos.after.isEmpty
    }

    /// Clear cached photos for an incident after upload completes
    /// - Parameter incidentId: The incident ID
    func clearPhotos(for incidentId: String) {
        print("🗑️ LocalPhotoCache: Clearing cached photos for incident \(incidentId)")
        cache.removeValue(forKey: incidentId)
    }

    /// Clear all cached photos (useful for memory pressure or logout)
    func clearAll() {
        print("🗑️ LocalPhotoCache: Clearing all cached photos")
        cache.removeAll()
    }
}

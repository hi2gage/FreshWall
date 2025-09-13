import CoreLocation
@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - LocationCache

/// Cache for storing address lookups to speed up repeated location operations
@MainActor
final class LocationCache {
    static let shared = LocationCache()

    private var addressCache: [String: CachedAddress] = [:]
    private let cacheExpirationInterval: TimeInterval = 24 * 60 * 60 // 24 hours
    private let proximityThreshold: CLLocationDistance = 100 // 100 meters

    private init() {}

    /// Gets cached address for coordinates if available and not expired
    func getCachedAddress(for coordinates: GeoPoint) -> String? {
        let key = cacheKey(for: coordinates)

        // Check exact match first
        if let cached = addressCache[key], !cached.isExpired {
            return cached.address
        }

        // Check for nearby cached addresses
        let coordinate = CLLocationCoordinate2D(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        )

        for (_, cached) in addressCache where !cached.isExpired {
            let cachedCoordinate = CLLocationCoordinate2D(
                latitude: cached.coordinates.latitude,
                longitude: cached.coordinates.longitude
            )
            let distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                .distance(from: CLLocation(
                    latitude: cachedCoordinate.latitude,
                    longitude: cachedCoordinate.longitude
                ))

            if distance <= proximityThreshold {
                return cached.address
            }
        }

        return nil
    }

    /// Stores address in cache for given coordinates
    func cacheAddress(_ address: String, for coordinates: GeoPoint) {
        let key = cacheKey(for: coordinates)
        addressCache[key] = CachedAddress(
            coordinates: coordinates,
            address: address,
            timestamp: Date()
        )

        // Clean up expired entries periodically
        cleanupExpiredEntries()
    }

    /// Clears all cached addresses
    func clearCache() {
        addressCache.removeAll()
    }

    /// Gets cache statistics for debugging
    var cacheInfo: (count: Int, expiredCount: Int) {
        let expired = addressCache.values.count(where: { $0.isExpired })
        return (count: addressCache.count, expiredCount: expired)
    }

    // MARK: - Private Methods

    private func cacheKey(for coordinates: GeoPoint) -> String {
        // Round to ~11m precision for caching (5 decimal places)
        let lat = round(coordinates.latitude * 100_000) / 100_000
        let lon = round(coordinates.longitude * 100_000) / 100_000
        return "\(lat),\(lon)"
    }

    private func cleanupExpiredEntries() {
        // Only cleanup if we have too many entries
        guard addressCache.count > 100 else { return }

        addressCache = addressCache.filter { !$0.value.isExpired }
    }
}

// MARK: - CachedAddress

private struct CachedAddress {
    let coordinates: GeoPoint
    let address: String
    let timestamp: Date

    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > 24 * 60 * 60 // 24 hours
    }
}

import Foundation

/// Container for shared services to avoid singleton pattern while maintaining single instances
@MainActor
final class ServiceContainer {
    static let shared = ServiceContainer()

    lazy var locationCache: LocationCacheProtocol = LocationCache()
    lazy var addressResolutionService = AddressResolutionService(locationCache: locationCache)

    private init() {}
}

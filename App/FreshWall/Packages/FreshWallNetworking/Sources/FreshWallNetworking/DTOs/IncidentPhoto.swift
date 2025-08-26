import Foundation

public struct IncidentPhoto: Codable, Sendable {
    public let id: String
    public let url: String
    public let captureDate: Date?
    public let latitude: Double?
    public let longitude: Double?

    public init(
        id: String,
        url: String,
        captureDate: Date? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.url = url
        self.captureDate = captureDate
        self.latitude = latitude
        self.longitude = longitude
    }

    public var hasLocation: Bool {
        latitude != nil && longitude != nil
    }
}

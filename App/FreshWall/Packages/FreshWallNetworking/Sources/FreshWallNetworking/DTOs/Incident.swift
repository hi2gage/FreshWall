import Foundation

// MARK: - Incident

public struct Incident: Codable, Sendable {
    public let id: String
    public let projectTitle: String
    public let clientId: String?
    public let workerIds: [String]
    public let description: String
    public let area: Double
    public let createdAt: Date
    public let startTime: Date
    public let endTime: Date
    public let beforePhotos: [IncidentPhoto]
    public let afterPhotos: [IncidentPhoto]
    public let createdById: String
    public let lastModifiedById: String?
    public let lastModifiedAt: Date?
    public let billable: Bool
    public let rate: Double?
    public let status: String
    public let materialsUsed: String?

    public init(
        id: String,
        projectTitle: String,
        clientId: String? = nil,
        workerIds: [String] = [],
        description: String,
        area: Double,
        createdAt: Date,
        startTime: Date,
        endTime: Date,
        beforePhotos: [IncidentPhoto] = [],
        afterPhotos: [IncidentPhoto] = [],
        createdById: String,
        lastModifiedById: String? = nil,
        lastModifiedAt: Date? = nil,
        billable: Bool = true,
        rate: Double? = nil,
        status: String = "open",
        materialsUsed: String? = nil
    ) {
        self.id = id
        self.projectTitle = projectTitle
        self.clientId = clientId
        self.workerIds = workerIds
        self.description = description
        self.area = area
        self.createdAt = createdAt
        self.startTime = startTime
        self.endTime = endTime
        self.beforePhotos = beforePhotos
        self.afterPhotos = afterPhotos
        self.createdById = createdById
        self.lastModifiedById = lastModifiedById
        self.lastModifiedAt = lastModifiedAt
        self.billable = billable
        self.rate = rate
        self.status = status
        self.materialsUsed = materialsUsed
    }
}

// MARK: - IncidentCreate

public struct IncidentCreate: Sendable {
    public let projectTitle: String
    public let clientId: String?
    public let workerIds: [String]
    public let description: String
    public let area: Double
    public let startTime: Date
    public let endTime: Date
    public let beforePhotos: [IncidentPhoto]
    public let afterPhotos: [IncidentPhoto]
    public let billable: Bool
    public let rate: Double?
    public let status: String
    public let materialsUsed: String?

    public init(
        projectTitle: String,
        clientId: String? = nil,
        workerIds: [String] = [],
        description: String,
        area: Double,
        startTime: Date,
        endTime: Date,
        beforePhotos: [IncidentPhoto] = [],
        afterPhotos: [IncidentPhoto] = [],
        billable: Bool = true,
        rate: Double? = nil,
        status: String = "open",
        materialsUsed: String? = nil
    ) {
        self.projectTitle = projectTitle
        self.clientId = clientId
        self.workerIds = workerIds
        self.description = description
        self.area = area
        self.startTime = startTime
        self.endTime = endTime
        self.beforePhotos = beforePhotos
        self.afterPhotos = afterPhotos
        self.billable = billable
        self.rate = rate
        self.status = status
        self.materialsUsed = materialsUsed
    }
}

// MARK: - IncidentUpdate

public struct IncidentUpdate: Sendable {
    public let projectTitle: String?
    public let clientId: String?
    public let workerIds: [String]?
    public let description: String?
    public let area: Double?
    public let startTime: Date?
    public let endTime: Date?
    public let beforePhotos: [IncidentPhoto]?
    public let afterPhotos: [IncidentPhoto]?
    public let billable: Bool?
    public let rate: Double?
    public let status: String?
    public let materialsUsed: String?

    public init(
        projectTitle: String? = nil,
        clientId: String? = nil,
        workerIds: [String]? = nil,
        description: String? = nil,
        area: Double? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        beforePhotos: [IncidentPhoto]? = nil,
        afterPhotos: [IncidentPhoto]? = nil,
        billable: Bool? = nil,
        rate: Double? = nil,
        status: String? = nil,
        materialsUsed: String? = nil
    ) {
        self.projectTitle = projectTitle
        self.clientId = clientId
        self.workerIds = workerIds
        self.description = description
        self.area = area
        self.startTime = startTime
        self.endTime = endTime
        self.beforePhotos = beforePhotos
        self.afterPhotos = afterPhotos
        self.billable = billable
        self.rate = rate
        self.status = status
        self.materialsUsed = materialsUsed
    }
}

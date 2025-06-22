import FirebaseFirestore
import Foundation

/// Domain model representing an incident used by the UI layer.
struct Incident: Identifiable, Hashable, Sendable {
    var id: String?
    var projectTitle: String
    var clientRef: DocumentReference
    var workerRefs: [DocumentReference]
    var description: String
    var area: Double
    var createdAt: Timestamp
    var startTime: Timestamp
    var endTime: Timestamp
    var beforePhotoUrls: [String]
    var afterPhotoUrls: [String]
    var createdBy: DocumentReference
    var lastModifiedBy: DocumentReference?
    var lastModifiedAt: Timestamp?
    var billable: Bool
    var rate: Double?
    var status: String
    var materialsUsed: String?
}

extension Incident {
    /// Creates a domain model from a DTO.
    init(dto: IncidentDTO) {
        self.id = dto.id
        self.projectTitle = dto.projectTitle
        self.clientRef = dto.clientRef
        self.workerRefs = dto.workerRefs
        self.description = dto.description
        self.area = dto.area
        self.createdAt = dto.createdAt
        self.startTime = dto.startTime
        self.endTime = dto.endTime
        self.beforePhotoUrls = dto.beforePhotoUrls
        self.afterPhotoUrls = dto.afterPhotoUrls
        self.createdBy = dto.createdBy
        self.lastModifiedBy = dto.lastModifiedBy
        self.lastModifiedAt = dto.lastModifiedAt
        self.billable = dto.billable
        self.rate = dto.rate
        self.status = dto.status
        self.materialsUsed = dto.materialsUsed
    }

    /// Converts the domain model back to a DTO for persistence.
    var dto: IncidentDTO {
        IncidentDTO(
            id: id,
            projectTitle: projectTitle,
            clientRef: clientRef,
            workerRefs: workerRefs,
            description: description,
            area: area,
            createdAt: createdAt,
            startTime: startTime,
            endTime: endTime,
            beforePhotoUrls: beforePhotoUrls,
            afterPhotoUrls: afterPhotoUrls,
            createdBy: createdBy,
            lastModifiedBy: lastModifiedBy,
            lastModifiedAt: lastModifiedAt,
            billable: billable,
            rate: rate,
            status: status,
            materialsUsed: materialsUsed
        )
    }
}

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
    var beforePhotos: [IncidentPhoto]
    var afterPhotos: [IncidentPhoto]
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
        id = dto.id
        projectTitle = dto.projectTitle
        clientRef = dto.clientRef
        workerRefs = dto.workerRefs
        description = dto.description
        area = dto.area
        createdAt = dto.createdAt
        startTime = dto.startTime
        endTime = dto.endTime
        beforePhotos = dto.beforePhotos.map { IncidentPhoto(dto: $0) }
        afterPhotos = dto.afterPhotos.map { IncidentPhoto(dto: $0) }
        createdBy = dto.createdBy
        lastModifiedBy = dto.lastModifiedBy
        lastModifiedAt = dto.lastModifiedAt
        billable = dto.billable
        rate = dto.rate
        status = dto.status
        materialsUsed = dto.materialsUsed
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
            beforePhotos: beforePhotos.map { $0.dto },
            afterPhotos: afterPhotos.map { $0.dto },
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

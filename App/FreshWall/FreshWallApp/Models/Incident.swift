import FirebaseFirestore
import Foundation

// MARK: - Incident

/// Domain model representing an incident used by the UI layer.
struct Incident: Identifiable, Hashable, Sendable {
    var id: String?
    var clientRef: DocumentReference?
    var description: String
    var area: Double
    var location: GeoPoint?
    var createdAt: Timestamp
    var startTime: Timestamp
    var endTime: Timestamp
    var beforePhotos: [IncidentPhoto]
    var afterPhotos: [IncidentPhoto]
    var createdBy: DocumentReference
    var lastModifiedBy: DocumentReference?
    var lastModifiedAt: Timestamp?
    var rate: Double?
    var materialsUsed: String?
}

extension Incident {
    /// Creates a domain model from a DTO.
    init(dto: IncidentDTO) {
        id = dto.id
        clientRef = dto.clientRef
        description = dto.description
        area = dto.area
        location = dto.location
        createdAt = dto.createdAt
        startTime = dto.startTime
        endTime = dto.endTime
        beforePhotos = dto.beforePhotos.map { IncidentPhoto(dto: $0) }
        afterPhotos = dto.afterPhotos.map { IncidentPhoto(dto: $0) }
        createdBy = dto.createdBy
        lastModifiedBy = dto.lastModifiedBy
        lastModifiedAt = dto.lastModifiedAt
        rate = dto.rate
        materialsUsed = dto.materialsUsed
    }

    /// Converts the domain model back to a DTO for persistence.
    var dto: IncidentDTO {
        IncidentDTO(
            id: id,
            clientRef: clientRef,
            description: description,
            area: area,
            location: location,
            createdAt: createdAt,
            startTime: startTime,
            endTime: endTime,
            beforePhotos: beforePhotos.map(\.dto),
            afterPhotos: afterPhotos.map(\.dto),
            createdBy: createdBy,
            lastModifiedBy: lastModifiedBy,
            lastModifiedAt: lastModifiedAt,
            rate: rate,
            materialsUsed: materialsUsed
        )
    }
}

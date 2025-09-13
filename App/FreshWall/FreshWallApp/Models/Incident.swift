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
    var status: IncidentStatus

    // MARK: - Enhanced Metadata

    /// Enhanced location data with address and capture method
    var enhancedLocation: IncidentLocation?
    /// Type of surface being worked on
    var surfaceType: SurfaceType?
    /// Structured notes system for different work stages
    var enhancedNotes: IncidentNotes?
    /// Custom surface description when surfaceType is .other
    var customSurfaceDescription: String?
}

extension Incident {
    /// Creates a domain model from a DTO.
    init(dto: IncidentDTO) {
        id = dto.id
        clientRef = dto.clientRef
        description = dto.description
        area = dto.area
        location = nil // Legacy field, data is now in enhancedLocation
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
        status = dto.status

        // Enhanced metadata
        enhancedLocation = dto.enhancedLocation
        surfaceType = dto.surfaceType
        enhancedNotes = dto.enhancedNotes
        customSurfaceDescription = dto.customSurfaceDescription
    }

    /// Converts the domain model back to a DTO for persistence.
    var dto: IncidentDTO {
        IncidentDTO(
            id: id,
            clientRef: clientRef,
            description: description,
            area: area,
            createdAt: createdAt,
            startTime: startTime,
            endTime: endTime,
            beforePhotos: beforePhotos.map(\.dto),
            afterPhotos: afterPhotos.map(\.dto),
            createdBy: createdBy,
            lastModifiedBy: lastModifiedBy,
            lastModifiedAt: lastModifiedAt,
            rate: rate,
            materialsUsed: materialsUsed,
            status: status,
            enhancedLocation: enhancedLocation,
            surfaceType: surfaceType,
            enhancedNotes: enhancedNotes,
            customSurfaceDescription: customSurfaceDescription
        )
    }
}

// MARK: - Convenience Properties

extension Incident {
    /// Returns the best available location data, prioritizing enhanced location over legacy
    var bestLocation: IncidentLocation? {
        if let enhancedLocation {
            return enhancedLocation
        }

        // Convert legacy location to enhanced location for consistent access
        if let legacyLocation = location {
            return IncidentLocation(legacyGeoPoint: legacyLocation)
        }

        return nil
    }

    /// Returns the best available notes, prioritizing enhanced notes over legacy description
    var bestNotes: IncidentNotes {
        if let enhancedNotes {
            return enhancedNotes
        }

        // Convert legacy description to enhanced notes for consistent access
        return IncidentNotes(legacyDescription: description.isEmpty ? nil : description)
    }

    /// Returns display-ready surface type string
    var surfaceDisplayName: String {
        guard let surfaceType else { return "Unknown Surface" }

        if surfaceType == .other, let customDescription = customSurfaceDescription, !customDescription.trimmingCharacters(in: .whitespaces).isEmpty {
            return customDescription
        }

        return surfaceType.displayName
    }

    /// Whether this incident has enhanced metadata (used for migration tracking)
    var hasEnhancedMetadata: Bool {
        enhancedLocation != nil || surfaceType != nil || enhancedNotes != nil
    }
}

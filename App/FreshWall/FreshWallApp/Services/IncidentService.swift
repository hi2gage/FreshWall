import FirebaseAuth
@preconcurrency import FirebaseFirestore
import Foundation

/// Protocol defining operations for fetching and managing Incident entities.
protocol IncidentServiceProtocol: Sendable {
    /// Fetches incidents for the current team.
    func fetchIncidents() async throws -> [Incident]
    /// Adds a new incident via full Incident model.
    func addIncident(_ incident: Incident) async throws
    /// Adds a new incident using an input value object and optional images.
    func addIncident(
        _ input: AddIncidentInput,
        beforeImages: [Data],
        afterImages: [Data]
    ) async throws
    /// Updates an existing incident using an input value object and optional images.
    func updateIncident(
        _ incidentId: String,
        with input: UpdateIncidentInput,
        beforeImages: [Data],
        afterImages: [Data]
    ) async throws
}

/// Service to fetch and manage Incident entities from Firestore.
struct IncidentService: IncidentServiceProtocol {
    private let modelService: IncidentModelServiceProtocol
    private let photoService: IncidentPhotoServiceProtocol
    private let clientModelService: ClientModelServiceProtocol
    private let userModelService: UserModelServiceProtocol
    private let metadataService: PhotoMetadataServiceProtocol
    private let session: UserSession

    /// Initializes the service with a `Firestore` instance and `UserSession` for team context.
    init(
        modelService: IncidentModelServiceProtocol,
        photoService: IncidentPhotoServiceProtocol,
        clientModelService: ClientModelServiceProtocol,
        userModelService: UserModelServiceProtocol,
        metadataService: PhotoMetadataServiceProtocol,
        session: UserSession
    ) {
        self.modelService = modelService
        self.photoService = photoService
        self.clientModelService = clientModelService
        self.userModelService = userModelService
        self.metadataService = metadataService
        self.session = session
    }

    /// Fetches active incidents for the current team from Firestore.
    func fetchIncidents() async throws -> [Incident] {
        let teamId = session.teamId

        let dtos = try await modelService.fetchIncidents(teamId: teamId)
        return dtos.map { Incident(dto: $0) }
    }

    /// Adds a new incident document to Firestore under the current team.
    ///
    /// - Parameter incident: The `Incident` model to add (with `id == nil`).
    /// - Throws: An error if the Firestore write fails or teamId is missing.
    func addIncident(_ incident: Incident) async throws {
        let teamId = session.teamId

        let newDoc = modelService.newIncidentDocument(teamId: teamId)
        var dto = incident.dto
        dto.id = newDoc.documentID
        try await modelService.setIncident(dto, at: newDoc)
    }

    /// Adds a new incident using an input value object and optional images.
    func addIncident(
        _ input: AddIncidentInput,
        beforeImages: [Data],
        afterImages: [Data]
    ) async throws {
        let teamId = session.teamId

        let newDoc = modelService.newIncidentDocument(teamId: teamId)
        let clientRef = clientModelService.clientDocument(teamId: teamId, clientId: input.clientId)
        let uid = Auth.auth().currentUser?.uid ?? ""
        let createdByRef = userModelService.userDocument(teamId: teamId, userId: uid)
        let beforeUrls = try await photoService.uploadBeforePhotos(
            teamId: teamId,
            incidentId: newDoc.documentID,
            images: beforeImages
        )

        let afterUrls = try await photoService.uploadAfterPhotos(
            teamId: teamId,
            incidentId: newDoc.documentID,
            images: afterImages
        )

        let beforePhotos = zip(beforeImages, beforeUrls).map { data, url -> IncidentPhotoDTO in
            let meta = metadataService.metadata(from: data)
            return IncidentPhotoDTO(
                url: url,
                captureDate: meta.captureDate.map { Timestamp(date: $0) },
                location: meta.location.map { GeoPoint(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            )
        }

        let afterPhotos = zip(afterImages, afterUrls).map { data, url -> IncidentPhotoDTO in
            let meta = metadataService.metadata(from: data)
            return IncidentPhotoDTO(
                url: url,
                captureDate: meta.captureDate.map { Timestamp(date: $0) },
                location: meta.location.map { GeoPoint(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            )
        }

        let newIncident = IncidentDTO(
            id: newDoc.documentID,
            projectTitle: input.projectTitle,
            clientRef: clientRef,
            workerRefs: [],
            description: input.description,
            area: input.area,
            createdAt: Timestamp(date: Date()),
            startTime: Timestamp(date: input.startTime),
            endTime: Timestamp(date: input.endTime),
            beforePhotos: beforePhotos,
            afterPhotos: afterPhotos,
            createdBy: createdByRef,
            lastModifiedBy: nil,
            lastModifiedAt: nil,
            billable: input.billable,
            rate: input.rate,
            status: input.status,
            materialsUsed: input.materialsUsed
        )
        try await modelService.setIncident(newIncident, at: newDoc)
        try await fetchIncidents()
    }

    /// Updates an existing incident document in Firestore.
    func updateIncident(
        _ incidentId: String,
        with input: UpdateIncidentInput,
        beforeImages: [Data],
        afterImages: [Data]
    ) async throws {
        let teamId = session.teamId

        let clientRef = clientModelService.clientDocument(teamId: teamId, clientId: input.clientId)

        let uid = Auth.auth().currentUser?.uid ?? ""
        let modifiedByRef = userModelService.userDocument(teamId: teamId, userId: uid)

        var data: [String: Any] = [
            "clientRef": clientRef,
            "description": input.description,
            "area": input.area,
            "startTime": Timestamp(date: input.startTime),
            "endTime": Timestamp(date: input.endTime),
            "billable": input.billable,
            "status": input.status,
            "lastModifiedBy": modifiedByRef,
            "lastModifiedAt": FieldValue.serverTimestamp(),
        ]

        if let rate = input.rate {
            data["rate"] = rate
        } else {
            data["rate"] = FieldValue.delete()
        }

        data["projectTitle"] = input.projectTitle

        if let materialsUsed = input.materialsUsed {
            data["materialsUsed"] = materialsUsed
        } else {
            data["materialsUsed"] = FieldValue.delete()
        }

        let newBeforeUrls = try await photoService.uploadBeforePhotos(
            teamId: teamId,
            incidentId: incidentId,
            images: beforeImages
        )
        let beforePhotos = zip(beforeImages, newBeforeUrls).map { data, url -> [String: Any] in
            let meta = metadataService.metadata(from: data)
            let dto = IncidentPhotoDTO(
                url: url,
                captureDate: meta.captureDate.map { Timestamp(date: $0) },
                location: meta.location.map { GeoPoint(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            )
            return dto.dictionary
        }
        if !beforePhotos.isEmpty {
            data["beforePhotos"] = FieldValue.arrayUnion(beforePhotos)
        }

        let newAfterUrls = try await photoService.uploadAfterPhotos(
            teamId: teamId,
            incidentId: incidentId,
            images: afterImages
        )
        let afterPhotos = zip(afterImages, newAfterUrls).map { data, url -> [String: Any] in
            let meta = metadataService.metadata(from: data)
            let dto = IncidentPhotoDTO(
                url: url,
                captureDate: meta.captureDate.map { Timestamp(date: $0) },
                location: meta.location.map { GeoPoint(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            )
            return dto.dictionary
        }
        if !afterPhotos.isEmpty {
            data["afterPhotos"] = FieldValue.arrayUnion(afterPhotos)
        }

        try await modelService.updateIncident(id: incidentId, teamId: teamId, data: data)
    }
}

extension IncidentService {
    enum Errors: Error {
        case missingTeamId
    }
}

import FirebaseAuth
@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - IncidentServiceProtocol

/// Protocol defining operations for fetching and managing Incident entities.
protocol IncidentServiceProtocol: Sendable {
    /// Fetches incidents for the current team.
    func fetchIncidents() async throws -> [Incident]
    /// Fetches a specific incident by ID.
    func fetchIncident(id: String) async throws -> Incident?
    /// Adds a new incident via full Incident model.
    func addIncident(_ incident: Incident) async throws
    /// Adds a new incident using an input value object and optional images.
    func addIncident(
        _ input: AddIncidentInput,
        beforePhotos: [PickedPhoto],
        afterPhotos: [PickedPhoto]
    ) async throws -> String
    /// Updates an existing incident using an input value object and optional images.
    func updateIncident(
        _ incidentId: String,
        with input: UpdateIncidentInput,
        newBeforePhotos: [PickedPhoto],
        newAfterPhotos: [PickedPhoto],
        photosToDelete: [String]
    ) async throws
    /// Deletes an existing incident.
    func deleteIncident(_ incidentId: String) async throws
}

// MARK: - IncidentService

/// Service to fetch and manage Incident entities from Firestore.
@MainActor
final class IncidentService: IncidentServiceProtocol {
    private let modelService: IncidentModelServiceProtocol
    private let photoService: IncidentPhotoServiceProtocol
    private let clientModelService: ClientModelServiceProtocol
    private let userModelService: UserModelServiceProtocol
    private let session: UserSession

    // Cache
    private var cachedIncidents: [Incident] = []
    private var listenerRegistration: ListenerRegistration?

    /// Initializes the service with a `Firestore` instance and `UserSession` for team context.
    init(
        modelService: IncidentModelServiceProtocol,
        photoService: IncidentPhotoServiceProtocol,
        clientModelService: ClientModelServiceProtocol,
        userModelService: UserModelServiceProtocol,
        session: UserSession
    ) {
        self.modelService = modelService
        self.photoService = photoService
        self.clientModelService = clientModelService
        self.userModelService = userModelService
        self.session = session
    }

    deinit {
        listenerRegistration?.remove()
    }

    /// Fetches active incidents for the current team from Firestore.
    /// Returns cached incidents immediately if available, otherwise fetches from Firestore.
    /// Sets up a real-time listener for automatic updates.
    func fetchIncidents() async throws -> [Incident] {
        let teamId = session.teamId

        // If we have cached data and a listener is active, return cache immediately
        if !cachedIncidents.isEmpty, listenerRegistration != nil {
            return cachedIncidents
        }

        // Set up real-time listener if not already listening
        if listenerRegistration == nil {
            setupIncidentsListener(teamId: teamId)
        }

        // Fetch initial data
        let dtos = try await modelService.fetchIncidents(teamId: teamId)
        cachedIncidents = dtos.map { Incident(dto: $0) }
        return cachedIncidents
    }

    /// Sets up a Firestore listener for real-time incident updates
    private func setupIncidentsListener(teamId: String) {
        let query = Firestore.firestore()
            .collection("teams").document(teamId)
            .collection("incidents")
            .order(by: "createdAt", descending: true)

        listenerRegistration = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }

            if let error {
                print("❌ Incidents listener error: \(error)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            Task { @MainActor in
                self.cachedIncidents = documents.compactMap { doc in
                    try? Incident(dto: doc.data(as: IncidentDTO.self))
                }
                print("🔄 Incidents cache updated: \(self.cachedIncidents.count) incidents")
            }
        }
    }

    /// Fetches a specific incident by ID from Firestore.
    func fetchIncident(id: String) async throws -> Incident? {
        let teamId = session.teamId

        let docRef = Firestore.firestore()
            .collection("teams").document(teamId)
            .collection("incidents").document(id)

        let document = try await docRef.getDocument()

        guard document.exists else {
            print("ℹ️ Incident document \(id) doesn't exist")
            return nil
        }

        let dto = try document.data(as: IncidentDTO.self)
        print("✅ Fetched specific incident: \(dto.description)")
        return Incident(dto: dto)
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
    /// Photos are uploaded in the background after incident creation for immediate user feedback.
    func addIncident(
        _ input: AddIncidentInput,
        beforePhotos: [PickedPhoto],
        afterPhotos: [PickedPhoto]
    ) async throws -> String {
        let teamId = session.teamId

        let newDoc = modelService.newIncidentDocument(teamId: teamId)
        let clientRef = input.clientId.map { id in
            clientModelService.clientDocument(teamId: teamId, clientId: id)
        }
        let uid = Auth.auth().currentUser?.uid ?? ""
        let createdByRef = userModelService.userDocument(teamId: teamId, userId: uid)

        let newIncident = IncidentDTO(
            id: nil,
            clientRef: clientRef,
            description: input.description,
            area: input.area,
            createdAt: Timestamp(date: Date()),
            startTime: Timestamp(date: input.startTime),
            endTime: Timestamp(date: input.endTime),
            beforePhotos: [],
            afterPhotos: [],
            createdBy: createdByRef,
            lastModifiedBy: nil,
            lastModifiedAt: nil,
            rate: input.rate,
            materialsUsed: input.materialsUsed,
            status: .inProgress,
            enhancedLocation: input.enhancedLocation,
            surfaceType: input.surfaceType,
            enhancedNotes: input.enhancedNotes,
            customSurfaceDescription: input.customSurfaceDescription
        )

        try await modelService.setIncident(newIncident, at: newDoc)

        if !beforePhotos.isEmpty || !afterPhotos.isEmpty {
            await BackgroundUploadService.shared.startUpload(
                incidentId: newDoc.documentID,
                teamId: teamId,
                beforePhotos: beforePhotos,
                afterPhotos: afterPhotos
            )
        }

        return newDoc.documentID
    }

    /// Updates an existing incident document in Firestore.
    func updateIncident(
        _ incidentId: String,
        with input: UpdateIncidentInput,
        newBeforePhotos: [PickedPhoto],
        newAfterPhotos: [PickedPhoto],
        photosToDelete: [String]
    ) async throws {
        let teamId = session.teamId

        let clientRef = input.clientId.map { clientModelService.clientDocument(teamId: teamId, clientId: $0) }

        let uid = Auth.auth().currentUser?.uid ?? ""
        let modifiedByRef = userModelService.userDocument(teamId: teamId, userId: uid)

        var data: [String: Any] = [
            "clientRef": clientRef as Any,
            "description": input.description,
            "area": input.area,
            "startTime": Timestamp(date: input.startTime),
            "endTime": Timestamp(date: input.endTime),
            "lastModifiedBy": modifiedByRef,
            "lastModifiedAt": FieldValue.serverTimestamp(),
        ]

        if let rate = input.rate {
            data["rate"] = rate
        } else {
            data["rate"] = FieldValue.delete()
        }

        if let materialsUsed = input.materialsUsed {
            data["materialsUsed"] = materialsUsed
        } else {
            data["materialsUsed"] = FieldValue.delete()
        }

        // Enhanced metadata fields
        if let enhancedLocation = input.enhancedLocation {
            data["enhancedLocation"] = enhancedLocation.dictionary
        } else {
            data["enhancedLocation"] = FieldValue.delete()
        }

        if let surfaceType = input.surfaceType {
            data["surfaceType"] = surfaceType.rawValue
        } else {
            data["surfaceType"] = FieldValue.delete()
        }

        if let enhancedNotes = input.enhancedNotes {
            data["enhancedNotes"] = enhancedNotes.dictionary
        } else {
            data["enhancedNotes"] = FieldValue.delete()
        }

        if let customSurfaceDescription = input.customSurfaceDescription {
            data["customSurfaceDescription"] = customSurfaceDescription
        } else {
            data["customSurfaceDescription"] = FieldValue.delete()
        }

        // Handle photo deletions
        if !photosToDelete.isEmpty {
            // First, fetch the current incident to get all photo data
            guard let currentIncident = try await fetchIncident(id: incidentId) else {
                throw Errors.missingTeamId
            }

            // Delete photos from storage
            let storage = StorageService()
            for url in photosToDelete {
                try? await storage.deleteFile(at: url)
            }

            // Remove photos from Firestore arrays
            let photosToRemove = (currentIncident.beforePhotos + currentIncident.afterPhotos)
                .filter { photosToDelete.contains($0.url) }
                .map(\.dto.dictionary)

            if !photosToRemove.isEmpty {
                data["beforePhotos"] = FieldValue.arrayRemove(photosToRemove.filter { dict in
                    currentIncident.beforePhotos.contains { $0.dto.dictionary["url"] as? String == dict["url"] as? String }
                })
                data["afterPhotos"] = FieldValue.arrayRemove(photosToRemove.filter { dict in
                    currentIncident.afterPhotos.contains { $0.dto.dictionary["url"] as? String == dict["url"] as? String }
                })
            }
        }

        // Upload and add new photos
        let beforeData = newBeforePhotos.compactMap { $0.image.jpegData(compressionQuality: 0.8) }
        if !beforeData.isEmpty {
            let newBeforeUrls = try await photoService.uploadBeforePhotos(
                teamId: teamId,
                incidentId: incidentId,
                images: beforeData
            )
            let beforePhotoDicts = newBeforePhotos
                .toIncidentPhotoDTOs(urls: newBeforeUrls)
                .map(\.dictionary)
            data["beforePhotos"] = FieldValue.arrayUnion(beforePhotoDicts)
        }

        let afterData = newAfterPhotos.compactMap { $0.image.jpegData(compressionQuality: 0.8) }
        if !afterData.isEmpty {
            let newAfterUrls = try await photoService.uploadAfterPhotos(
                teamId: teamId,
                incidentId: incidentId,
                images: afterData
            )
            let afterPhotoDicts = newAfterPhotos
                .toIncidentPhotoDTOs(urls: newAfterUrls)
                .map(\.dictionary)
            data["afterPhotos"] = FieldValue.arrayUnion(afterPhotoDicts)
        }

        try await modelService.updateIncident(id: incidentId, teamId: teamId, data: data)
    }

    /// Deletes an existing incident document from Firestore.
    func deleteIncident(_ incidentId: String) async throws {
        let teamId = session.teamId
        try await modelService.deleteIncident(id: incidentId, teamId: teamId)
    }
}

// MARK: IncidentService.Errors

extension IncidentService {
    enum Errors: Error {
        case missingTeamId
    }
}

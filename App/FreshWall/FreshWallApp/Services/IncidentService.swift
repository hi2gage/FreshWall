import FirebaseAuth
@preconcurrency import FirebaseFirestore
import Foundation

/// Protocol defining operations for fetching and managing Incident entities.
protocol IncidentServiceProtocol: Sendable {
    /// Fetches incidents for the current team.
    func fetchIncidents() async throws -> [IncidentDTO]
    /// Adds a new incident via full Incident model.
    func addIncident(_ incident: IncidentDTO) async throws
    /// Adds a new incident using an input value object.
    func addIncident(_ input: AddIncidentInput) async throws
    /// Updates an existing incident using an input value object.
    func updateIncident(_ incidentId: String, with input: UpdateIncidentInput) async throws
}

/// Service to fetch and manage Incident entities from Firestore.
struct IncidentService: IncidentServiceProtocol {
    private let firestore: Firestore
    private let session: UserSession

    /// Initializes the service with a `Firestore` instance and `UserSession` for team context.
    init(firestore: Firestore, session: UserSession) {
        self.firestore = firestore
        self.session = session
    }

    /// Fetches active incidents for the current team from Firestore.
    func fetchIncidents() async throws -> [IncidentDTO] {
        let teamId = session.teamId

        let snapshot = try await firestore
            .collection("teams")
            .document(teamId)
            .collection("incidents")
            .getDocuments()
        let fetched: [IncidentDTO] = try snapshot.documents.compactMap {
            try $0.data(as: IncidentDTO.self)
        }
        return fetched
    }

    /// Adds a new incident document to Firestore under the current team.
    ///
    /// - Parameter incident: The `Incident` model to add (with `id == nil`).
    /// - Throws: An error if the Firestore write fails or teamId is missing.
    func addIncident(_ incident: IncidentDTO) async throws {
        let teamId = session.teamId

        let incidentsRef = firestore
            .collection("teams")
            .document(teamId)
            .collection("incidents")
        let newDoc = incidentsRef.document()
        var newIncident = incident
        newIncident.id = newDoc.documentID
        try await newDoc.setData(from: newIncident)
    }

    /// Adds a new incident using an input value object.
    func addIncident(_ input: AddIncidentInput) async throws {
        let teamId = session.teamId

        let incidentsRef = firestore
            .collection("teams")
            .document(teamId)
            .collection("incidents")
        let newDoc = incidentsRef.document()
        let clientRef = firestore
            .collection("teams")
            .document(teamId)
            .collection("clients")
            .document(input.clientId)
        let uid = Auth.auth().currentUser?.uid ?? ""
        let createdByRef = firestore
            .collection("teams")
            .document(teamId)
            .collection("users")
            .document(uid)
        let newIncident = IncidentDTO(
            id: newDoc.documentID,
            clientRef: clientRef,
            workerRefs: [],
            description: input.description,
            area: input.area,
            createdAt: Timestamp(date: Date()),
            startTime: Timestamp(date: input.startTime),
            endTime: Timestamp(date: input.endTime),
            beforePhotoUrls: [],
            afterPhotoUrls: [],
            createdBy: createdByRef,
            lastModifiedBy: nil,
            lastModifiedAt: nil,
            billable: input.billable,
            rate: input.rate,
            projectName: input.projectName,
            status: input.status,
            materialsUsed: input.materialsUsed
        )
        try await newDoc.setData(from: newIncident)
        try await fetchIncidents()
    }

    /// Updates an existing incident document in Firestore.
    func updateIncident(_ incidentId: String, with input: UpdateIncidentInput) async throws {
        let teamId = session.teamId

        let incidentRef = firestore
            .collection("teams")
            .document(teamId)
            .collection("incidents")
            .document(incidentId)

        let clientRef = firestore
            .collection("teams")
            .document(teamId)
            .collection("clients")
            .document(input.clientId)

        let uid = Auth.auth().currentUser?.uid ?? ""
        let modifiedByRef = firestore
            .collection("teams")
            .document(teamId)
            .collection("users")
            .document(uid)

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

        if let projectName = input.projectName {
            data["projectName"] = projectName
        } else {
            data["projectName"] = FieldValue.delete()
        }

        if let materialsUsed = input.materialsUsed {
            data["materialsUsed"] = materialsUsed
        } else {
            data["materialsUsed"] = FieldValue.delete()
        }

        try await incidentRef.updateData(data)
    }
}

extension IncidentService {
    enum Errors: Error {
        case missingTeamId
    }
}

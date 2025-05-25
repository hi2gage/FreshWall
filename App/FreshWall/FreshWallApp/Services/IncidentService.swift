import FirebaseAuth
@preconcurrency import FirebaseFirestore
import Foundation

/// Protocol defining operations for fetching and managing Incident entities.
protocol IncidentServiceProtocol: Sendable {
    /// Fetches incidents for the current team.
    func fetchIncidents() async throws -> [Incident]
    /// Adds a new incident via full Incident model.
    func addIncident(_ incident: Incident) async throws
    /// Adds a new incident using an input value object.
    func addIncident(_ input: AddIncidentInput) async throws
}

/// Service to fetch and manage Incident entities from Firestore.
struct IncidentService: IncidentServiceProtocol {
    private let firestore: Firestore
    private let session: UserSession

    /// Initializes the service with the given UserService for team context.
    /// Initializes the service with a Firestore instance and UserService for team context.
    init(firestore: Firestore, session: UserSession) {
        self.firestore = firestore
        self.session = session
    }

    /// Fetches active incidents for the current team from Firestore.
    func fetchIncidents() async throws -> [Incident] {
        let teamId = session.teamId

        let snapshot = try await firestore
            .collection("teams")
            .document(teamId)
            .collection("incidents")
            .getDocuments()
        let fetched: [Incident] = try snapshot.documents.compactMap {
            try $0.data(as: Incident.self)
        }
        return fetched
    }

    /// Adds a new incident document to Firestore under the current team.
    ///
    /// - Parameter incident: The `Incident` model to add (with `id == nil`).
    /// - Throws: An error if the Firestore write fails or teamId is missing.
    func addIncident(_ incident: Incident) async throws {
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
        let newIncident = Incident(
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
}

extension IncidentService {
    enum Errors: Error {
        case missingTeamId
    }
}

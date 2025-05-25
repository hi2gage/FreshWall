@preconcurrency import FirebaseFirestore
import Foundation
import Observation

/// Protocol defining operations for fetching and managing Incident entities.
protocol IncidentServiceProtocol: Sendable {
    /// Fetches incidents for the current team.
    func fetchIncidents() async throws -> [Incident]
    /// Adds a new incident to the current team's incidents collection.
    func addIncident(_ incident: Incident) async throws
}

/// Service to fetch and manage Incident entities from Firestore.
@MainActor
@Observable
final class IncidentService: IncidentServiceProtocol {
    private let database: Firestore
    private let userService: UserService

    /// Initializes the service with the given UserService for team context.
    /// Initializes the service with a Firestore instance and UserService for team context.
    init(firestore: Firestore, userService: UserService) {
        database = firestore
        self.userService = userService
    }

    /// Fetches active incidents for the current team from Firestore.
    func fetchIncidents() async throws -> [Incident] {
        guard let teamId = userService.teamId else {
            throw Errors.missingTeamId
        }
        let snapshot = try await database
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
        guard let teamId = userService.teamId else {
            throw NSError(domain: "IncidentService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Missing team ID"])
        }
        let incidentsRef = database
            .collection("teams")
            .document(teamId)
            .collection("incidents")
        let newDoc = incidentsRef.document()
        var newIncident = incident
        newIncident.id = newDoc.documentID
        try await newDoc.setData(from: newIncident)
        try await fetchIncidents()
    }
}

extension IncidentService {
    enum Errors: Error {
        case missingTeamId
    }
}

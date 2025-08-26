import Foundation

public protocol IncidentRepository {
    func createIncident(teamId: String, incident: IncidentCreate) async throws -> Incident
    func getIncident(incidentId: String, teamId: String) async throws -> Incident
    func getIncidentsForClient(clientId: String, teamId: String) async throws -> [Incident]
    func getIncidentsForTeam(teamId: String) async throws -> [Incident]
    func updateIncident(incidentId: String, teamId: String, updates: IncidentUpdate) async throws
    func deleteIncident(incidentId: String, teamId: String) async throws
}

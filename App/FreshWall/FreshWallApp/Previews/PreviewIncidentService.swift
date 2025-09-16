import Foundation

@MainActor
final class PreviewIncidentService: IncidentServiceProtocol {
    func fetchIncidents() async throws -> [Incident] {
        []
    }

    func fetchIncident(id: String) async throws -> Incident? {
        // Return nil for previews - could be enhanced with mock data if needed
        print("🎭 PreviewIncidentService.fetchIncident called with id: \(id)")
        return nil
    }

    func addIncident(_: Incident) async throws {
        // No-op implementation for previews
    }

    func addIncident(
        _: AddIncidentInput,
        beforePhotos _: [PickedPhoto],
        afterPhotos _: [PickedPhoto]
    ) async throws -> String {
        "preview-incident-id"
    }

    func updateIncident(
        _: String,
        with _: UpdateIncidentInput,
        beforePhotos _: [PickedPhoto],
        afterPhotos _: [PickedPhoto]
    ) async throws {
        // No-op implementation for previews
    }

    func deleteIncident(_: String) async throws {
        // No-op implementation for previews
    }
}

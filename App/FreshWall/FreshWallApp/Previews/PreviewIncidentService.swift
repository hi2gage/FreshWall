import Foundation

@MainActor
final class PreviewIncidentService: IncidentServiceProtocol {
    func fetchIncidents() async throws -> [Incident] {
        []
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

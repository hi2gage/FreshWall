@testable import FreshWall

final class IncidentServiceProtocolMock: IncidentServiceProtocol {
    var updateArgs: (String, UpdateIncidentInput)?
    var addIncidentWithInputResult: String = "mock-id"

    func fetchIncidents() async throws -> [Incident] {
        []
    }

    func addIncident(_: Incident) async throws {
        // No-op implementation for testing
    }

    func addIncident(
        _: AddIncidentInput,
        beforePhotos _: [PickedPhoto],
        afterPhotos _: [PickedPhoto]
    ) async throws -> String {
        addIncidentWithInputResult
    }

    func updateIncident(
        _ id: String,
        with input: UpdateIncidentInput,
        beforePhotos _: [PickedPhoto],
        afterPhotos _: [PickedPhoto]
    ) async throws {
        updateArgs = (id, input)
    }

    func deleteIncident(_: String) async throws {
        // No-op implementation for testing
    }
}

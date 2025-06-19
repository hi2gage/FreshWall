@testable import FreshWall
import FirebaseFirestore
import Testing

struct IncidentServiceCompositionTests {
    final actor MockModel: IncidentModelServiceProtocol {
        var added: IncidentDTO?
        var updateData: [String: Any]?
        func fetchIncidents(teamId _: String) async throws -> [IncidentDTO] { [] }
        func setIncident(_ incident: IncidentDTO, at _: DocumentReference) async throws { added = incident }
        func newIncidentDocument(teamId _: String) -> DocumentReference { Firestore.firestore().document("teams/t/incidents/i") }
        func updateIncident(id _: String, teamId _: String, data: [String : Any]) async throws { updateData = data }
    }

    final actor MockPhoto: IncidentPhotoServiceProtocol {
        func uploadBeforePhotos(teamId _: String, incidentId _: String, images: [Data]) async throws -> [String] { images.map { _ in "before" } }
        func uploadAfterPhotos(teamId _: String, incidentId _: String, images: [Data]) async throws -> [String] { images.map { _ in "after" } }
    }

    @Test func addIncidentDelegates() async throws {
        let model = MockModel()
        let photo = MockPhoto()
        let session = UserSession(teamId: "t")
        let service = IncidentService(firestore: Firestore.firestore(), modelService: model, photoService: photo, session: session)
        let input = AddIncidentInput(
            clientId: "c", description: "d", area: 1, startTime: .init(), endTime: .init(), billable: false, rate: nil, projectName: nil, status: "open", materialsUsed: nil
        )
        try await service.addIncident(input, beforeImages: [Data()], afterImages: [])
        let added = await model.added
        #expect(added?.beforePhotoUrls.first == "before")
    }
}

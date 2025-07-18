import _PhotosUI_SwiftUI
import FirebaseFirestore
@testable import FreshWall
import Testing

struct IncidentServiceCompositionTests {
    final actor MockModel: IncidentModelServiceProtocol {
        var added: IncidentDTO?
        var updateData: [String: Any]?
        func fetchIncidents(teamId _: String) async throws -> [IncidentDTO] { [] }
        func setIncident(_ incident: IncidentDTO, at _: DocumentReference) async throws { added = incident }
        func newIncidentDocument(teamId _: String) -> DocumentReference { Firestore.firestore().document("teams/t/incidents/i") }
        func updateIncident(id _: String, teamId _: String, data: [String: Any]) async throws { updateData = data }
    }

    final actor MockPhoto: IncidentPhotoServiceProtocol {
        func uploadBeforePhotos(teamId _: String, incidentId _: String, images: [Data]) async throws -> [String] { images.map { _ in "before" } }
        func uploadAfterPhotos(teamId _: String, incidentId _: String, images: [Data]) async throws -> [String] { images.map { _ in "after" } }
    }

    final actor MockClientModel: ClientModelServiceProtocol {
        var requested: (String, String)?
        func fetchClients(teamId _: String) async throws -> [ClientDTO] { [] }
        func newClientDocument(teamId _: String) -> DocumentReference { Firestore.firestore().document("c") }
        func setClient(_: ClientDTO, at _: DocumentReference) async throws {}
        func updateClient(id _: String, teamId _: String, data _: [String: Any]) async throws {}
        func clientDocument(teamId: String, clientId: String) -> DocumentReference {
            requested = (teamId, clientId)
            return Firestore.firestore().document("teams/\(teamId)/clients/\(clientId)")
        }
    }

    final actor MockUserModel: UserModelServiceProtocol {
        var requested: (String, String)?
        func userDocument(teamId: String, userId: String) -> DocumentReference {
            requested = (teamId, userId)
            return Firestore.firestore().document("teams/\(teamId)/users/\(userId)")
        }
    }

    @Test func addIncidentDelegates() async throws {
        let model = MockModel()
        let photo = MockPhoto()
        let clientModel = MockClientModel()
        let userModel = MockUserModel()
        let session = UserSession(teamId: "t")
        let service = IncidentService(
            modelService: model,
            photoService: photo,
            clientModelService: clientModel,
            userModelService: userModel,
            session: session
        )
        let input = AddIncidentInput(
            clientId: "c", description: "d", area: 1, startTime: .init(), endTime: .init(), billable: false, rate: nil, projectTitle: "", status: "open", materialsUsed: nil
        )
        let renderer = UIGraphicsImageRenderer(size: .init(width: 1, height: 1))
        let image = renderer.image { _ in }
        let photo = PickedPhoto(image: image, captureDate: nil, location: nil)
        try await service.addIncident(input, beforePhotos: [photo], afterPhotos: [])
        let added = await model.added
        let clientArgs = await clientModel.requested
        let userArgs = await userModel.requested
        #expect(added?.beforePhotos.first?.url == "before")
        #expect(clientArgs?.1 == "c")
        #expect(userArgs?.0 == "t")
    }
}

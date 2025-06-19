@preconcurrency import FirebaseFirestore
@testable import FreshWall
import Testing

struct ClientServiceCompositionTests {
    final actor MockModel: ClientModelServiceProtocol {
        var added: ClientDTO?
        var updateData: [String: Any]?
        func fetchClients(teamId _: String, sortedBy _: ClientSortOption) async throws -> [ClientDTO] { [] }
        func newClientDocument(teamId _: String) -> DocumentReference { Firestore.firestore().document("c") }
        func setClient(_ client: ClientDTO, at _: DocumentReference) async throws { added = client }
        func updateClient(id _: String, teamId _: String, data: [String: Any]) async throws { updateData = data }
        func clientDocument(teamId _: String, clientId _: String) -> DocumentReference { Firestore.firestore().document("c") }
    }

    @Test func addDelegates() async throws {
        let model = MockModel()
        let session = UserSession(userId: "u", displayName: "", teamId: "t")
        let service = ClientService(firestore: Firestore.firestore(), modelService: model, session: session)
        let input = AddClientInput(name: "n", notes: nil, lastIncidentAt: .init())
        try await service.addClient(input)
        let added = await model.added
        #expect(added?.name == "n")
    }
}

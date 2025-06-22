import FirebaseFirestore
@testable import FreshWall
import Testing

@MainActor
struct EditIncidentViewModelTests {
    final class MockIncidentService: IncidentServiceProtocol {
        var updateArgs: (String, UpdateIncidentInput)?
        func fetchIncidents() async throws -> [Incident] { [] }
        func addIncident(_: Incident) async throws {}
        func addIncident(
            _: AddIncidentInput,
            beforePhotos _: [PickedPhoto],
            afterPhotos _: [PickedPhoto]
        ) async throws {}
        func updateIncident(
            _ id: String,
            with input: UpdateIncidentInput,
            beforePhotos _: [PickedPhoto],
            afterPhotos _: [PickedPhoto]
        ) async throws {
            updateArgs = (id, input)
        }
    }

    final class MockClientService: ClientServiceProtocol {
        func fetchClients(sortedBy _: ClientSortOption) async throws -> [Client] { [] }
        func addClient(_: AddClientInput) async throws {}
        func updateClient(_: String, with _: UpdateClientInput) async throws {}
    }

    @Test func validation() {
        let incidentService = MockIncidentService()
        let clientService = MockClientService()
        let incident = Incident(
            id: "1",
            clientRef: Firestore.firestore().document("teams/t/clients/c"),
            workerRefs: [],
            description: "d",
            area: 1,
            createdAt: Timestamp(date: .init()),
            startTime: Timestamp(date: .init()),
            endTime: Timestamp(date: .init()),
            beforePhotos: [],
            afterPhotos: [],
            createdBy: Firestore.firestore().document("teams/t/users/u"),
            lastModifiedBy: nil,
            lastModifiedAt: nil,
            billable: false,
            rate: nil,
            projectTitle: "",
            status: "open",
            materialsUsed: nil
        )
        let vm = EditIncidentViewModel(incident: incident, incidentService: incidentService, clientService: clientService)
        vm.description = ""
        vm.clientId = ""
        vm.projectTitle = ""
        #expect(vm.isValid == false)
        vm.clientId = "c"
        vm.description = "test"
        vm.projectTitle = "Title"
        #expect(vm.isValid == true)
    }

    @Test func saveCallsService() async throws {
        let incidentService = MockIncidentService()
        let clientService = MockClientService()
        let incident = Incident(
            id: "1",
            clientRef: Firestore.firestore().document("teams/t/clients/c"),
            workerRefs: [],
            description: "old",
            area: 1,
            createdAt: Timestamp(date: .init()),
            startTime: Timestamp(date: .init()),
            endTime: Timestamp(date: .init()),
            beforePhotos: [],
            afterPhotos: [],
            createdBy: Firestore.firestore().document("teams/t/users/u"),
            lastModifiedBy: nil,
            lastModifiedAt: nil,
            billable: false,
            rate: nil,
            projectTitle: "",
            status: "open",
            materialsUsed: nil
        )
        let vm = EditIncidentViewModel(incident: incident, incidentService: incidentService, clientService: clientService)
        vm.description = "new"
        try await vm.save(beforePhotos: [], afterPhotos: [])
        #expect(incidentService.updateArgs?.0 == "1")
        #expect(incidentService.updateArgs?.1.description == "new")
    }
}

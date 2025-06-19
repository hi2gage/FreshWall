import FirebaseFirestore
@testable import FreshWall
import Testing

@MainActor
struct EditIncidentViewModelTests {
    final class MockIncidentService: IncidentServiceProtocol {
        var updateArgs: (String, UpdateIncidentInput)?
        func fetchIncidents() async throws -> [IncidentDTO] { [] }
        func addIncident(_: IncidentDTO) async throws {}
        func addIncident(
            _ : AddIncidentInput,
            beforeImages _: [Data],
            afterImages _: [Data]
        ) async throws {}
        func updateIncident(
            _ id: String,
            with input: UpdateIncidentInput,
            beforeImages _: [Data],
            afterImages _: [Data]
        ) async throws {
            updateArgs = (id, input)
        }
    }

    final class MockClientService: ClientServiceProtocol {
        func fetchClients(sortedBy _: ClientSortOption) async throws -> [ClientDTO] { [] }
        func addClient(_: AddClientInput) async throws {}
        func updateClient(_: String, with _: UpdateClientInput) async throws {}
    }

    @Test func validation() {
        let incidentService = MockIncidentService()
        let clientService = MockClientService()
        let incident = IncidentDTO(
            id: "1",
            clientRef: Firestore.firestore().document("teams/t/clients/c"),
            workerRefs: [],
            description: "d",
            area: 1,
            createdAt: Timestamp(date: .init()),
            startTime: Timestamp(date: .init()),
            endTime: Timestamp(date: .init()),
            beforePhotoUrls: [],
            afterPhotoUrls: [],
            createdBy: Firestore.firestore().document("teams/t/users/u"),
            lastModifiedBy: nil,
            lastModifiedAt: nil,
            billable: false,
            rate: nil,
            projectName: nil,
            status: "open",
            materialsUsed: nil
        )
        let vm = EditIncidentViewModel(incident: incident, incidentService: incidentService, clientService: clientService)
        vm.description = ""
        vm.clientId = ""
        #expect(vm.isValid == false)
        vm.clientId = "c"
        vm.description = "test"
        #expect(vm.isValid == true)
    }

    @Test func saveCallsService() async throws {
        let incidentService = MockIncidentService()
        let clientService = MockClientService()
        let incident = IncidentDTO(
            id: "1",
            clientRef: Firestore.firestore().document("teams/t/clients/c"),
            workerRefs: [],
            description: "old",
            area: 1,
            createdAt: Timestamp(date: .init()),
            startTime: Timestamp(date: .init()),
            endTime: Timestamp(date: .init()),
            beforePhotoUrls: [],
            afterPhotoUrls: [],
            createdBy: Firestore.firestore().document("teams/t/users/u"),
            lastModifiedBy: nil,
            lastModifiedAt: nil,
            billable: false,
            rate: nil,
            projectName: nil,
            status: "open",
            materialsUsed: nil
        )
        let vm = EditIncidentViewModel(incident: incident, incidentService: incidentService, clientService: clientService)
        vm.description = "new"
        try await vm.save(beforeImages: [], afterImages: [])
        #expect(incidentService.updateArgs?.0 == "1")
        #expect(incidentService.updateArgs?.1.description == "new")
    }
}

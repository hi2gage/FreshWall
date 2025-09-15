import FirebaseFirestore
@testable import FreshWall
import Testing

@MainActor
struct EditIncidentViewModelTests {
    @Test func validation() {
        let incidentService = IncidentServiceProtocolMock()
        let clientService = ClientServiceProtocolMock()
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
        let incidentService = IncidentServiceProtocolMock()
        let clientService = ClientServiceProtocolMock()
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

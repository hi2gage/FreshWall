import FirebaseFirestore
@testable import FreshWall
import Testing

@MainActor
struct ClientsListViewModelTests {
    @Test func sortAlphabeticalAscending() {
        let clientService = ClientServiceProtocolMock()
        let incidentService = IncidentServiceProtocolMock()
        let vm = ClientsListViewModel(clientService: clientService, incidentService: incidentService)
        vm.clients = [
            Client(id: "1", name: "B", notes: nil, isDeleted: false, deletedAt: nil, createdAt: .init(), lastIncidentAt: .init()),
            Client(id: "2", name: "A", notes: nil, isDeleted: false, deletedAt: nil, createdAt: .init(), lastIncidentAt: .init()),
        ]
        vm.sortField = .alphabetical
        vm.isAscending = true
        let sorted = vm.sortedClients()
        #expect(sorted.first?.name == "A")
    }

    @Test func sortByDateDescending() {
        let clientService = ClientServiceProtocolMock()
        let incidentService = IncidentServiceProtocolMock()
        let vm = ClientsListViewModel(clientService: clientService, incidentService: incidentService)
        let clientRefA = Firestore.firestore().document("teams/t/clients/a")
        let clientRefB = Firestore.firestore().document("teams/t/clients/b")
        vm.clients = [
            Client(id: "a", name: "A", notes: nil, isDeleted: false, deletedAt: nil, createdAt: .init(), lastIncidentAt: .init()),
            Client(id: "b", name: "B", notes: nil, isDeleted: false, deletedAt: nil, createdAt: .init(), lastIncidentAt: .init()),
        ]
        var first = Incident(
            id: "1",
            clientRef: clientRefA,
            workerRefs: [],
            description: "d",
            area: 1,
            createdAt: Timestamp(date: Date()),
            startTime: Timestamp(date: Date()),
            endTime: Timestamp(date: Date()),
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
        var second = first
        second.id = "2"
        second.clientRef = clientRefB
        second.createdAt = Timestamp(date: Date().addingTimeInterval(60))
        vm.incidents = [first, second]
        vm.sortField = .incidentDate
        vm.isAscending = false
        let sorted = vm.sortedClients()
        #expect(sorted.first?.id == "b")
    }
}

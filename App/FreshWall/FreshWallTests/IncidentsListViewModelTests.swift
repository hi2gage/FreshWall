import FirebaseFirestore
@testable import FreshWall
import Testing

@MainActor
struct IncidentsListViewModelTests {
    final class MockService: IncidentServiceProtocol {
        func fetchIncidents() async throws -> [IncidentDTO] { [] }
        func addIncident(_: IncidentDTO) async throws {}
        func addIncident(_: AddIncidentInput, beforeImages _: [Data], afterImages _: [Data]) async throws {}
        func updateIncident(_: String, with _: UpdateIncidentInput, beforeImages _: [Data], afterImages _: [Data]) async throws {}
    }

    @Test func groupingByClient() {
        let service = MockService()
        let vm = IncidentsListViewModel(service: service)
        let clientRefA = Firestore.firestore().document("teams/t/clients/a")
        let clientRefB = Firestore.firestore().document("teams/t/clients/b")
        let baseIncident = IncidentDTO(
            id: "1",
            clientRef: clientRefA,
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
        var second = baseIncident
        second.id = "2"
        second.clientRef = clientRefB
        vm.incidents = [baseIncident, second]

        let clients = [
            ClientDTO(id: "a", name: "A", notes: nil, isDeleted: false, deletedAt: nil, createdAt: .init(), lastIncidentAt: .init()),
            ClientDTO(id: "b", name: "B", notes: nil, isDeleted: false, deletedAt: nil, createdAt: .init(), lastIncidentAt: .init())
        ]

        let grouped = vm.groupedIncidents(by: .client, clients: clients)
        #expect(grouped.count == 2)
        #expect(grouped[0].title == "A")
        #expect(grouped[1].title == "B")
    }

    @Test func groupingNone() {
        let service = MockService()
        let vm = IncidentsListViewModel(service: service)
        vm.incidents = []
        let groups = vm.groupedIncidents(by: .none, clients: [])
        #expect(groups.count == 1)
        #expect(groups.first?.incidents.isEmpty == true)
    }
}

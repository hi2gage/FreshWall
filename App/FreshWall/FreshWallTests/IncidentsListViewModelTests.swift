import FirebaseFirestore
@testable import FreshWall
import Testing

@MainActor
struct IncidentsListViewModelTests {
    final class MockService: IncidentServiceProtocol {
        func fetchIncidents() async throws -> [Incident] { [] }
        func addIncident(_: Incident) async throws {}
        func addIncident(_: AddIncidentInput, beforePhotos _: [PickedPhoto], afterPhotos _: [PickedPhoto]) async throws {}
        func updateIncident(_: String, with _: UpdateIncidentInput, beforePhotos _: [PickedPhoto], afterPhotos _: [PickedPhoto]) async throws {}
    }

    final class MockClientService: ClientServiceProtocol {
        func fetchClients() async throws -> [Client] { [] }
        func addClient(_: AddClientInput) async throws {}
        func updateClient(_: String, with _: UpdateClientInput) async throws {}
    }

    @Test func groupingByClient() {
        let service = MockService()
        let clientService = MockClientService()
        let vm = IncidentsListViewModel(incidentService: service, clientService: clientService)
        let clientRefA = Firestore.firestore().document("teams/t/clients/a")
        let clientRefB = Firestore.firestore().document("teams/t/clients/b")
        let baseIncident = Incident(
            id: "1",
            clientRef: clientRefA,
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
        var second = baseIncident
        second.id = "2"
        second.clientRef = clientRefB
        vm.incidents = [baseIncident, second]
        vm.groupOption = .client
        vm.clients = [
            Client(id: "a", name: "A", notes: nil, isDeleted: false, deletedAt: nil, createdAt: .init(), lastIncidentAt: .init()),
            Client(id: "b", name: "B", notes: nil, isDeleted: false, deletedAt: nil, createdAt: .init(), lastIncidentAt: .init()),
        ]

        vm.isAscending = true
        let grouped = vm.groupedIncidents()
        #expect(grouped.count == 2)
        #expect(grouped[0].title == "A")
        #expect(grouped[1].title == "B")
    }

    @Test func groupingNone() {
        let service = MockService()
        let clientService = MockClientService()
        let vm = IncidentsListViewModel(incidentService: service, clientService: clientService)
        vm.groupOption = .none
        vm.incidents = []
        vm.clients = []
        let groups = vm.groupedIncidents()
        #expect(groups.count == 1)
        #expect(groups.first?.incidents.isEmpty == true)
    }

    @Test func groupingByDate() {
        let service = MockService()
        let clientService = MockClientService()
        let vm = IncidentsListViewModel(incidentService: service, clientService: clientService)
        let clientRef = Firestore.firestore().document("teams/t/clients/a")
        let baseDate = Date()
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: baseDate)!
        let first = Incident(
            id: "1",
            clientRef: clientRef,
            workerRefs: [],
            description: "d",
            area: 1,
            createdAt: Timestamp(date: baseDate),
            startTime: Timestamp(date: baseDate),
            endTime: Timestamp(date: baseDate),
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
        second.startTime = Timestamp(date: nextDay)
        second.createdAt = Timestamp(date: nextDay)
        second.endTime = Timestamp(date: nextDay)
        vm.incidents = [first, second]
        vm.groupOption = .date
        vm.isAscending = true

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let groups = vm.groupedIncidents()
        #expect(groups.count == 2)
        #expect(groups[0].title == formatter.string(from: Calendar.current.startOfDay(for: baseDate)))
        #expect(groups[0].items.count == 1)
        #expect(groups[1].title == formatter.string(from: Calendar.current.startOfDay(for: nextDay)))
        #expect(groups[1].items.count == 1)
    }

    @Test func sortAlphabeticalAscending() {
        let service = MockService()
        let clientService = MockClientService()
        let vm = IncidentsListViewModel(incidentService: service, clientService: clientService)
        let clientRef = Firestore.firestore().document("teams/t/clients/a")
        var first = Incident(
            id: "1",
            clientRef: clientRef,
            workerRefs: [],
            description: "B",
            area: 1,
            createdAt: .init(),
            startTime: .init(),
            endTime: .init(),
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
        second.description = "A"
        vm.groupOption = .none
        vm.sortField = .alphabetical
        vm.isAscending = true
        vm.incidents = [first, second]

        let groups = vm.groupedIncidents()
        #expect(groups.first?.items.first?.description == "A")
    }

    @Test func sortByDateDescendingGroupDate() {
        let service = MockService()
        let clientService = MockClientService()
        let vm = IncidentsListViewModel(incidentService: service, clientService: clientService)
        let clientRef = Firestore.firestore().document("teams/t/clients/a")
        let baseDate = Date()
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: baseDate)!
        var first = Incident(
            id: "1",
            clientRef: clientRef,
            workerRefs: [],
            description: "d",
            area: 1,
            createdAt: Timestamp(date: baseDate),
            startTime: Timestamp(date: baseDate),
            endTime: Timestamp(date: baseDate),
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
        second.startTime = Timestamp(date: nextDay)
        second.createdAt = Timestamp(date: nextDay)
        second.endTime = Timestamp(date: nextDay)
        vm.groupOption = .date
        vm.isAscending = false
        vm.incidents = [first, second]

        let groups = vm.groupedIncidents()
        #expect(groups.first?.title != groups.last?.title)
        #expect(groups.first?.items.first?.startTime.dateValue() == nextDay)
    }
}

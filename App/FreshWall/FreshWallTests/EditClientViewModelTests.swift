import FirebaseFirestore
@testable import FreshWall
import Testing

@MainActor
struct EditClientViewModelTests {
    @Test func validation() {
        let service = ClientServiceProtocolMock()
        let dto = Client(
            id: "1",
            name: "Test",
            notes: nil,
            isDeleted: false,
            deletedAt: nil,
            createdAt: Timestamp(date: .init()),
            lastIncidentAt: Timestamp(date: .init())
        )
        let vm = EditClientViewModel(client: dto, service: service)
        vm.name = ""
        #expect(vm.isValid == false)
        vm.name = "A"
        #expect(vm.isValid == true)
    }

    @Test func saveCallsService() async throws {
        let service = ClientServiceProtocolMock()
        let dto = Client(
            id: "1",
            name: "Old",
            notes: nil,
            isDeleted: false,
            deletedAt: nil,
            createdAt: Timestamp(date: .init()),
            lastIncidentAt: Timestamp(date: .init())
        )
        let vm = EditClientViewModel(client: dto, service: service)
        vm.name = "New"
        try await vm.save()
        #expect(service.updateArgs?.0 == "1")
        #expect(service.updateArgs?.1.name == "New")
    }
}

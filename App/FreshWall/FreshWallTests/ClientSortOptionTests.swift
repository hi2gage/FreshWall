@testable import FreshWall
import Testing

struct ClientSortOptionTests {
    @Test func fieldMappings() {
        #expect(ClientSortOption.nameAscending.field == "name")
        #expect(ClientSortOption.nameDescending.field == "name")
        #expect(ClientSortOption.lastIncidentAscending.field == "lastIncidentAt")
        #expect(ClientSortOption.lastIncidentDescending.field == "lastIncidentAt")
        #expect(ClientSortOption.createdAtAscending.field == "createdAt")
        #expect(ClientSortOption.createdAtDescending.field == "createdAt")
    }

    @Test func isDescendingValues() {
        #expect(ClientSortOption.nameAscending.isDescending == false)
        #expect(ClientSortOption.nameDescending.isDescending == true)
        #expect(ClientSortOption.lastIncidentAscending.isDescending == false)
        #expect(ClientSortOption.lastIncidentDescending.isDescending == true)
        #expect(ClientSortOption.createdAtAscending.isDescending == false)
        #expect(ClientSortOption.createdAtDescending.isDescending == true)
    }

    @Test func titlesAndSymbols() {
        #expect(ClientSortOption.nameAscending.title == "Name")
        #expect(ClientSortOption.nameAscending.symbolName == "arrowtriangle.up.fill")
        #expect(ClientSortOption.nameDescending.title == "Name")
        #expect(ClientSortOption.nameDescending.symbolName == "arrowtriangle.down.fill")
    }
}

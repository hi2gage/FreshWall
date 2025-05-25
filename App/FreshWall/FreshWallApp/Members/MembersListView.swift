import SwiftUI

/// A view displaying a list of team members.
struct MembersListView: View {
    @Environment(RouterPath.self) private var routerPath
    var body: some View {
        List {
            // TODO: Fetch and list members from Firestore
            Button("Sample Member") {
                routerPath.push(.memberDetail(id: "sampleMemberID"))
            }
        }
        .navigationTitle("Members")
    }
}

struct MembersListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MembersListView()
        }
    }
}

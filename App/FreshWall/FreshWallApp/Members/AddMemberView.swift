import SwiftUI

/// View for adding a new member, injecting a service conforming to `MemberServiceProtocol`.
struct AddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    let service: MemberServiceProtocol

    var body: some View {
        Text("Add Member View")
            .navigationTitle("Add Member")
    }
}

struct AddMemberView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddMemberView(service: PreviewMemberService())
        }
    }
}

/// Dummy implementation of `MemberServiceProtocol` for previews.
private class PreviewMemberService: MemberServiceProtocol {
    var members: [User] = []
    func fetchMembers() async {}
    func addMember(_: User) async throws {}
}

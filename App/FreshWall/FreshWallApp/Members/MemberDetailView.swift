import SwiftUI

/// A view displaying detailed information for a specific team member.
struct MemberDetailView: View {
    let memberId: String
    let userService: UserService

    var body: some View {
        Text("Details for member \(memberId)")
            .navigationTitle("Member Details")
    }
}

struct MemberDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MemberDetailView(memberId: "member123", userService: UserService())
        }
    }
}
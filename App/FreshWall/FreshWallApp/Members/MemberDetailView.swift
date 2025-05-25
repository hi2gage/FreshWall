import SwiftUI

/// A view displaying detailed information for a specific team member.
struct MemberDetailView: View {
    let memberId: String

    var body: some View {
        Text("Details for member \(memberId)")
            .navigationTitle("Member Details")
    }
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            MemberDetailView(memberId: "member123")
        }
    }
}

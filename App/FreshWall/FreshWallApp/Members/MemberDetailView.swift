import FirebaseFirestore
import SwiftUI

/// A view displaying detailed information for a specific team member.
/// A view displaying detailed information for a specific team member.
struct MemberDetailView: View {
    let member: Member

    var body: some View {
        List {
            Section("Member Info") {
                Text(member.displayName)
                    .font(.title2)
                HStack {
                    Text("Email")
                    Spacer()
                    Text(member.email)
                }
                HStack {
                    Text("Role")
                    Spacer()
                    Text(member.role.rawValue.capitalized)
                }
                HStack {
                    Text("Deleted?")
                    Spacer()
                    Text(member.isDeleted ? "Yes" : "No")
                }
                if let deletedAt = member.deletedAt {
                    HStack {
                        Text("Deleted At")
                        Spacer()
                        Text(deletedAt.dateValue(), style: .date)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Member Details")
        .refreshable {
            // No-op until member service supports reloading a single member
        }
    }
}

#Preview {
    let sampleMember = Member(
        id: "member123",
        displayName: "Jane Doe",
        email: "jane@example.com",
        role: .member,
        isDeleted: false,
        deletedAt: nil
    )
    FreshWallPreview {
        NavigationStack {
            MemberDetailView(member: sampleMember)
        }
    }
}

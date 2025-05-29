import SwiftUI

/// A cell view displaying summary information for a team member.
struct MemberListCell: View {
    let member: UserDTO

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(member.displayName)
                    .font(.headline)
                Text(member.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(member.role.rawValue.capitalized)
                .font(.subheadline)
                .padding(4)
                .background(roleColor.opacity(0.3))
                .cornerRadius(4)
        }
        .listCellStyle()
    }

    private var roleColor: Color {
        switch member.role {
        case .lead: return .blue
        case .member: return .gray
        }
    }
}

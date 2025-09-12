import SwiftUI

/// A cell view displaying summary information for a team member.
struct MemberListCell: View {
    let member: Member

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
            Text(member.role.displayName)
                .font(.subheadline)
                .foregroundColor(roleColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(roleColor.opacity(0.15))
                .cornerRadius(6)
        }
        .listCellStyle()
    }

    private var roleColor: Color {
        switch member.role {
        case .admin:
            .red
        case .manager:
            .blue
        case .fieldWorker:
            .green
        default:
            .gray
        }
    }
}

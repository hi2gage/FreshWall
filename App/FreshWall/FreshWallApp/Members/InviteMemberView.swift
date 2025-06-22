import SwiftUI

struct InviteMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: InviteMemberViewModel

    init(service: InviteCodeGenerating) {
        _viewModel = State(wrappedValue: InviteMemberViewModel(service: service))
    }

    var body: some View {
        VStack(spacing: 24) {
            if let code = viewModel.code {
                Text("Code: \(code)")
                    .font(.title)
                ShareLink(item: viewModel.shareMessage) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            } else {
                Text("Error try again later")
            }
            Spacer()
        }
        .task {
            await viewModel.generate()
        }
        .padding()
        .navigationTitle("Invite Member")
    }
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            InviteMemberView(service: InviteCodeService())
        }
    }
}

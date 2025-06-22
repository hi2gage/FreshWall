import SwiftUI

/// View for adding a new member, injecting a service conforming to `MemberServiceProtocol`.
struct AddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddMemberViewModel

    init(viewModel: AddMemberViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("Full Name", text: $viewModel.displayName)
            }
            Section("Email") {
                TextField("Email Address", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            Section("Role") {
                Picker("Role", selection: $viewModel.role) {
                    ForEach(UserRole.allCases, id: \ .self) { role in
                        Text(role.rawValue.capitalized).tag(role)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Add Member")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        do {
                            try await viewModel.save()
                            dismiss()
                        } catch {
                            // Handle error if needed
                        }
                    }
                }
                .disabled(!viewModel.isValid)
            }
        }
    }
}

/// Dummy implementation of `MemberServiceProtocol` for previews.
@MainActor
private class PreviewMemberService: MemberServiceProtocol {
    func fetchMembers() async throws -> [UserDTO] { [] }
    func addMember(_: UserDTO) async throws {}
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            AddMemberView(viewModel: AddMemberViewModel(service: PreviewMemberService()))
        }
    }
}

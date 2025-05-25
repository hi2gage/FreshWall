import SwiftUI

/// View for adding a new member, injecting a service conforming to `MemberServiceProtocol`.
import SwiftUI

struct AddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    let service: MemberServiceProtocol
    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var role: UserRole = .member

    var body: some View {
        Form {
            Section("Name") {
                TextField("Full Name", text: $displayName)
            }
            Section("Email") {
                TextField("Email Address", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            Section("Role") {
                Picker("Role", selection: $role) {
                    ForEach(UserRole.allCases, id: \ .self) { role in
                        Text(role.rawValue.capitalized).tag(role)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Add Member")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let member = User(
                        id: nil,
                        displayName: displayName,
                        email: email,
                        role: role,
                        isDeleted: false,
                        deletedAt: nil
                    )
                    Task {
                        try? await service.addMember(member)
                        dismiss()
                    }
                }
                .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty || email.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

/// Dummy implementation of `MemberServiceProtocol` for previews.
@MainActor
private class PreviewMemberService: MemberServiceProtocol {
    var members: [User] = []
    func fetchMembers() async throws -> [User] { [] }
    func addMember(_: User) async throws {}
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            AddMemberView(service: PreviewMemberService())
        }
    }
}

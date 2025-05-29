import SwiftUI
import FirebaseFirestore

/// A view displaying detailed information for a specific client.
struct ClientDetailView: View {
    let client: ClientDTO

    var body: some View {
        List {
            Section("Client Details") {
                Text(client.name)
                    .font(.title2)
                if let notes = client.notes, !notes.isEmpty {
                    Text(notes)
                } else {
                    Text("No notes")
                        .italic()
                }
                HStack {
                    Text("Created At")
                    Spacer()
                    Text(client.createdAt.dateValue(), style: .date)
                }
                HStack {
                    Text("Deleted?")
                    Spacer()
                    Text(client.isDeleted ? "Yes" : "No")
                }
                if let deletedAt = client.deletedAt {
                    HStack {
                        Text("Deleted At")
                        Spacer()
                        Text(deletedAt.dateValue(), style: .date)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Client Details")
    }
}

#Preview {
    let sampleClient = ClientDTO(
        id: "client123",
        name: "Test Client",
        notes: "Sample notes",
        isDeleted: false,
        deletedAt: nil,
        createdAt: Timestamp(date: Date())
    )
    FreshWallPreview {
        NavigationStack {
            ClientDetailView(client: sampleClient)
        }
    }
}

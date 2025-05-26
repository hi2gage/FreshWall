import SwiftUI
import FirebaseFirestore

/// A cell view displaying summary information for a client.
struct ClientListCell: View {
    let client: Client

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(client.name)
                .font(.headline)
            HStack {
                Text("Created: \\(client.createdAt.dateValue(), style: .date)")
                    .font(.subheadline)
                Spacer()
                Text(client.isDeleted ? "Deleted" : "Active")
                    .font(.subheadline)
                    .foregroundColor(client.isDeleted ? .red : .green)
            }
            if let notes = client.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .lineLimit(2)
            }
        }
        .listCellStyle()
    }
}
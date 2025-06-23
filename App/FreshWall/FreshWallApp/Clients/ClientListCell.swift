import FirebaseFirestore
import SwiftUI

/// A cell view displaying summary information for a client.
struct ClientListCell: View {
    let client: Client

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(client.name)
                .font(.headline)
            Text(client.createdAt.dateValue(), style: .date)
                .font(.subheadline)
            if let notes = client.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .lineLimit(2)
            }
        }
        .listCellStyle()
    }
}

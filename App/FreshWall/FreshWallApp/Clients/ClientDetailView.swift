import FirebaseFirestore
import SwiftUI

/// A view displaying detailed information for a specific client.
struct ClientDetailView: View {
    @State private var client: ClientDTO
    let incidentService: IncidentServiceProtocol
    let clientService: ClientServiceProtocol
    @Environment(RouterPath.self) private var routerPath
    @State private var incidents: [IncidentDTO] = []
    @State private var showingEdit = false

    init(client: ClientDTO,
         incidentService: IncidentServiceProtocol,
         clientService: ClientServiceProtocol)
    {
        _client = State(wrappedValue: client)
        self.incidentService = incidentService
        self.clientService = clientService
    }

    /// Reloads the client data after editing.
    private func reloadClient() {
        Task {
            guard let id = client.id else { return }
            let updatedClients = await (try? clientService.fetchClients(sortedBy: .createdAtAscending)) ?? []
            if let updated = updatedClients.first(where: { $0.id == id }) {
                client = updated
            }
        }
    }

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

                HStack {
                    Text("lastIncidentAt?")
                    Spacer()
                    Text(client.lastIncidentAt.description)
                }

                if let deletedAt = client.deletedAt {
                    HStack {
                        Text("Deleted At")
                        Spacer()
                        Text(deletedAt.dateValue(), style: .date)
                    }
                }
            }
            Section(header: Text("Incidents (\(incidents.count))")) {
                if incidents.isEmpty {
                    Text("No incidents for this client.")
                        .italic()
                } else {
                    ForEach(incidents) { incident in
                        Button(incident.description) {
                            routerPath.push(.incidentDetail(incident: incident))
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Client Details")
        .task {
            let all = await (try? incidentService.fetchIncidents()) ?? []
            incidents = all.filter { $0.clientRef.documentID == client.id }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Client Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit, onDismiss: reloadClient) {
            NavigationStack {
                EditClientView(
                    viewModel: EditClientViewModel(client: client, service: clientService)
                )
            }
        }
    }
}

//
// #Preview {
//    let sampleClient = ClientDTO(
//        id: "client123",
//        name: "Test Client",
//        notes: "Sample notes",
//        isDeleted: false,
//        deletedAt: nil,
//        createdAt: Timestamp(date: Date())
//    )
//    FreshWallPreview {
//        NavigationStack {
//            ClientDetailView(client: sampleClient)
//        }
//    }
// }

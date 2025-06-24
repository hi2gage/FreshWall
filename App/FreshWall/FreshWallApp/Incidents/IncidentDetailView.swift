@preconcurrency import FirebaseFirestore
import SwiftUI

/// A view displaying detailed information for a specific incident.
struct IncidentDetailView: View {
    @State private var incident: Incident
    let incidentService: IncidentServiceProtocol
    let clientService: ClientServiceProtocol
    @Environment(RouterPath.self) private var routerPath
    @State private var client: Client?

    init(incident: Incident, incidentService: IncidentServiceProtocol, clientService: ClientServiceProtocol) {
        _incident = State(wrappedValue: incident)
        self.incidentService = incidentService
        self.clientService = clientService
    }

    /// Reloads the incident after editing.
    private func reloadIncident() async {
        guard let id = incident.id else { return }

        let updated = await (try? incidentService.fetchIncidents()) ?? []
        if let match = updated.first(where: { $0.id == id }) {
            incident = match
        }
        await loadClient()
    }

    /// Loads the client associated with this incident.
    private func loadClient() async {
        let clients = await (try? clientService.fetchClients(sortedBy: .createdAtAscending)) ?? []
        client = clients.first { $0.id == incident.clientRef?.documentID }
    }

    var body: some View {
        List {
            Section("Project") {
                if incident.projectTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                    Button("Add Project Title") { routerPath.push(.editIncident(incident: incident)) }
                } else {
                    Text(incident.projectTitle)
                }
                if incident.area <= 0 {
                    Button("Add Square Footage") { routerPath.push(.editIncident(incident: incident)) }
                } else {
                    HStack {
                        Text("Area")
                        Spacer()
                        Text(String(format: "%.2f", incident.area) + " sq ft")
                    }
                }

                HStack {
                    Text("Status")
                    Spacer()
                    Text(incident.status.capitalized)
                }
            }
            Section("Photos") {
                if incident.beforePhotos.isEmpty {
                    Button("Add Before Photos") { routerPath.push(.editIncident(incident: incident)) }
                } else if let beforePhotos = incident.beforePhotos.nullIfEmpty {
                    Section("Before Photos") {
                        PhotoCarousel(photos: beforePhotos)
                    }
                }
                if incident.afterPhotos.isEmpty {
                    Button("Add After Photos") { routerPath.push(.editIncident(incident: incident)) }
                } else if let afterPhotos = incident.afterPhotos.nullIfEmpty {
                    Section("After Photos") {
                        PhotoCarousel(photos: afterPhotos)
                    }
                }
            }
            Section("Timeline") {
                HStack {
                    Text("Start Time")
                    Spacer()
                    Text(incident.startTime.dateValue(), style: .time)
                }
                HStack {
                    Text("End Time")
                    Spacer()
                    Text(incident.endTime.dateValue(), style: .time)
                }
            }

            Section("Client") {
                if let client {
                    Button(client.name) {
                        routerPath.push(.clientDetail(client: client))
                    }
                } else {
                    Button("Add Client") { routerPath.push(.editIncident(incident: incident)) }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Incident Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { routerPath.push(.editIncident(incident: incident)) }
            }
        }
        .onAppear {
            Task { await reloadIncident() }
        }
        .task {
            await loadClient()
        }
        .refreshable {
            await reloadIncident()
        }
    }
}

//
// #Preview {
//    let dummyRef = Firestore.firestore().document("teams/team123/clients/client123")
//    let sampleIncident = Incident(
//        id: "incident123",
//        clientRef: dummyRef,
//        workerRefs: [dummyRef],
//        description: "Graffiti removal at entrance",
//        area: 150.0,
//        createdAt: Timestamp(date: Date()),
//        startTime: Timestamp(date: Date()),
//        endTime: Timestamp(date: Date()),
//        beforePhotos: [IncidentPhoto(url: "https://via.placeholder.com/100", captureDate: nil, location: nil)],
//        afterPhotos: [IncidentPhoto(url: "https://via.placeholder.com/100", captureDate: nil, location: nil)],
//        createdBy: dummyRef,
//        lastModifiedBy: nil,
//        lastModifiedAt: nil,
//        billable: true,
//        rate: 75.0,
//        projectTitle: "Front Wall Project",
//        status: "completed",
//        materialsUsed: "Paint, brushes"
//    )
//    FreshWallPreview {
//        NavigationStack {
//            IncidentDetailView(incident: sampleIncident)
//        }
//    }
// }

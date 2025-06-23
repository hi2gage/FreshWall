@preconcurrency import FirebaseFirestore
import SwiftUI

/// A view displaying detailed information for a specific incident.
struct IncidentDetailView: View {
    @State private var incident: Incident
    let incidentService: IncidentServiceProtocol
    let clientService: ClientServiceProtocol
    @Environment(RouterPath.self) private var routerPath
    @State private var client: Client?
    @State private var showingEdit = false
    @State private var viewerContext: PhotoViewerContext?

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
        client = clients.first { $0.id == incident.clientRef.documentID }
    }

    var body: some View {
        List {
            Section("Overview") {
                Text(incident.projectTitle)
                if !incident.description.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text(incident.description)
                }
                HStack {
                    Text("Status")
                    Spacer()
                    Text(incident.status.capitalized)
                }
                HStack {
                    Text("Area")
                    Spacer()
                    Text(String(format: "%.2f", incident.area) + " sq ft")
                }
                HStack {
                    Text("Billable")
                    Spacer()
                    Text(incident.billable ? "Yes" : "No")
                }
                if let rate = incident.rate {
                    HStack {
                        Text("Rate")
                        Spacer()
                        Text("$" + String(format: "%.2f", rate))
                    }
                }
                if let materials = incident.materialsUsed, !materials.isEmpty {
                    HStack {
                        Text("Materials Used")
                        Spacer()
                        Text(materials)
                    }
                }
            }
            Section("Timeline") {
                HStack {
                    Text("Created At")
                    Spacer()
                    Text(incident.createdAt.dateValue(), style: .time)
                }
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
                if let modifiedAt = incident.lastModifiedAt {
                    HStack {
                        Text("Modified At")
                        Spacer()
                        Text(modifiedAt.dateValue(), style: .date)
                    }
                }
            }
            if let beforePhotos = incident.beforePhotos.nullIfEmpty {
                Section("Before Photos") {
                    PhotoCarousel(photos: beforePhotos)
                }
            }
            if let afterPhotos = incident.afterPhotos.nullIfEmpty {
                Section("After Photos") {
                    PhotoCarousel(photos: afterPhotos)
                }
            }
            if let client {
                Section("Client") {
                    Button(client.name) {
                        routerPath.push(.clientDetail(client: client))
                    }
                    if let notes = client.notes, !notes.isEmpty {
                        Text(notes)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Incident Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEdit = true }
            }
        }
        .asyncSheet(isPresented: $showingEdit, onDismiss: reloadIncident) {
            NavigationStack {
                EditIncidentView(
                    viewModel: EditIncidentViewModel(
                        incident: incident,
                        incidentService: incidentService,
                        clientService: clientService
                    )
                )
            }
        }
        .fullScreenCover(item: $viewerContext) { context in
            PhotoViewer(photos: context.photos, selectedPhoto: context.selectedPhoto)
        }
        .task {
            await loadClient()
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

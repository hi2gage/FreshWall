@preconcurrency import FirebaseFirestore
import SwiftUI

/// A view displaying detailed information for a specific incident.
struct IncidentDetailView: View {
    @State private var incident: Incident
    let incidentService: IncidentServiceProtocol
    let clientService: ClientServiceProtocol
    @Environment(RouterPath.self) private var routerPath
    @State private var client: Client?
    @State private var clients: [Client] = []

    // Inline editor states
    @State private var showingClientPicker = false
    @State private var selectedClientId: String? = nil
    @State private var pickedBeforePhotos: [PickedPhoto] = []
    @State private var pickedAfterPhotos: [PickedPhoto] = []

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
        clients = await (try? clientService.fetchClients()) ?? []
        client = clients.first { $0.id == incident.clientRef?.documentID }
        selectedClientId = incident.clientRef?.documentID
    }

    /// Updates the incident with new photos.
    private func updateIncidentWithPhotos(beforePhotos: [PickedPhoto], afterPhotos: [PickedPhoto]) async {
        guard let id = incident.id else { return }

        let input = UpdateIncidentInput(
            clientId: selectedClientId ?? incident.clientRef?.documentID,
            description: incident.description,
            area: incident.area,
            startTime: incident.startTime.dateValue(),
            endTime: incident.endTime.dateValue(),
            billable: incident.billable,
            rate: incident.rate,
            projectTitle: incident.projectTitle,
            status: incident.status,
            materialsUsed: incident.materialsUsed
        )

        do {
            try await incidentService.updateIncident(
                id,
                with: input,
                beforePhotos: beforePhotos,
                afterPhotos: afterPhotos
            )
            await reloadIncident()
        } catch {
            print("Failed to update incident with photos: \(error)")
        }
    }

    /// Updates the incident with new values.
    private func updateIncident() async {
        guard let id = incident.id else { return }

        let input = UpdateIncidentInput(
            clientId: selectedClientId ?? incident.clientRef?.documentID,
            description: incident.description,
            area: incident.area,
            startTime: incident.startTime.dateValue(),
            endTime: incident.endTime.dateValue(),
            billable: incident.billable,
            rate: incident.rate,
            projectTitle: incident.projectTitle,
            status: incident.status,
            materialsUsed: incident.materialsUsed
        )

        do {
            try await incidentService.updateIncident(
                id,
                with: input,
                beforePhotos: [],
                afterPhotos: []
            )
            await reloadIncident()
        } catch {
            print("Failed to update incident: \(error)")
        }
    }

    var body: some View {
        List {
            Section("Project") {
                HStack {
                    Text("Project Title")
                    Spacer()
                    Text(incident.projectTitle)
                        .foregroundColor(incident.projectTitle.isEmpty ? .secondary : .primary)
                }

                AddableAreaCell(
                    area: $incident.area,
                    onSave: updateIncident
                )

                AddableDescriptionCell(
                    description: $incident.description,
                    onSave: updateIncident
                )

                HStack {
                    Text("Status")
                    Spacer()
                    Text(incident.status.capitalized)
                }
            }
            Section("Photos") {
                if incident.beforePhotos.isEmpty {
                    PhotoSourcePicker(
                        selection: $pickedBeforePhotos,
                        maxSelectionCount: 10,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Add Before Photos", systemImage: "camera.fill")
                    }
                } else if let beforePhotos = incident.beforePhotos.nullIfEmpty {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Before Photos")
                            Spacer()
                            PhotoSourcePicker(
                                selection: $pickedBeforePhotos,
                                maxSelectionCount: 10,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        PhotoCarousel(photos: beforePhotos)
                    }
                }
                if incident.afterPhotos.isEmpty {
                    PhotoSourcePicker(
                        selection: $pickedAfterPhotos,
                        maxSelectionCount: 10,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Add After Photos", systemImage: "camera.fill")
                    }
                } else if let afterPhotos = incident.afterPhotos.nullIfEmpty {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("After Photos")
                            Spacer()
                            PhotoSourcePicker(
                                selection: $pickedAfterPhotos,
                                maxSelectionCount: 10,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.accentColor)
                            }
                        }
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
                AddableClientCell(
                    selectedClientId: $selectedClientId,
                    validClients: clients,
                    onAddNewClient: {
                        routerPath.push(.addClient)
                    },
                    onClientSelected: {
                        await updateIncident()
                    },
                    onNavigateToClient: { client in
                        routerPath.push(.clientDetail(client: client))
                    }
                )
//                AddableClientCell(
//                    selectedClientId: client,
//                    validClients: [],
//                    onAddNewClient: {},
//                    onClientSelected: {},
//                    onNavigateToClient { client in
//                        routerPath.push(.clientDetail(client: client))
//                    }
//                )
//                if let client {
//                    HStack {
//                        Button(client.name) {
//                            routerPath.push(.clientDetail(client: client))
//                        }
//                        Spacer()
//                        Button(action: { showingClientPicker = true }) {
//                            Image(systemName: "pencil")
//                                .foregroundColor(.accentColor)
//                        }
//                    }
//                } else {
//                    Button("Add Client") {
//                        showingClientPicker = true
//                    }
//                }
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
        .onChange(of: pickedBeforePhotos) { _, newPhotos in
            if !newPhotos.isEmpty {
                Task {
                    await updateIncidentWithPhotos(beforePhotos: newPhotos, afterPhotos: [])
                    pickedBeforePhotos.removeAll()
                }
            }
        }
        .onChange(of: pickedAfterPhotos) { _, newPhotos in
            if !newPhotos.isEmpty {
                Task {
                    await updateIncidentWithPhotos(beforePhotos: [], afterPhotos: newPhotos)
                    pickedAfterPhotos.removeAll()
                }
            }
        }
        .sheet(isPresented: $showingClientPicker) {
            InlineClientPicker(
                isPresented: $showingClientPicker,
                selectedClientId: $selectedClientId,
                clients: clients,
                onSave: updateIncident
            )
            .presentationDetents([.large])
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

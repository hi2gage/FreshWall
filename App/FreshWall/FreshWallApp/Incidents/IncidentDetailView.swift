@preconcurrency import FirebaseFirestore
import SwiftUI

/// A view displaying detailed information for a specific incident.
struct IncidentDetailView: View {
    @State private var viewModel: IncidentDetailViewModel
    @Environment(RouterPath.self) private var routerPath

    init(
        incident: Incident,
        incidentService: IncidentServiceProtocol,
        clientService: ClientServiceProtocol
    ) {
        _viewModel = State(wrappedValue: IncidentDetailViewModel(
            incident: incident,
            incidentService: incidentService,
            clientService: clientService
        ))
    }

    var body: some View {
        List {
            Section("Project") {
                AddableAreaCell(
                    area: $viewModel.incident.area,
                    onSave: {
                        await viewModel.updateIncident()
                    }
                )

                AddableDescriptionCell(
                    description: $viewModel.incident.description,
                    onSave: {
                        await viewModel.updateIncident()
                    }
                )
            }

            if let location = viewModel.incident.location {
                Section("Location") {
                    Text("📍 \(location.shortDisplayString)")
                }
            }

            Section("Photos") {
                if viewModel.incident.beforePhotos.isEmpty {
                    PhotoSourcePicker(
                        selection: $viewModel.pickedBeforePhotos,
                        maxSelectionCount: 10,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Add Before Photos", systemImage: "camera.fill")
                    }
                } else if let beforePhotos = viewModel.incident.beforePhotos.nullIfEmpty {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Before Photos")
                            Spacer()
                            PhotoSourcePicker(
                                selection: $viewModel.pickedBeforePhotos,
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
                if viewModel.incident.afterPhotos.isEmpty {
                    PhotoSourcePicker(
                        selection: $viewModel.pickedAfterPhotos,
                        maxSelectionCount: 10,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Add After Photos", systemImage: "camera.fill")
                    }
                } else if let afterPhotos = viewModel.incident.afterPhotos.nullIfEmpty {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("After Photos")
                            Spacer()
                            PhotoSourcePicker(
                                selection: $viewModel.pickedAfterPhotos,
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
                    Text(viewModel.incident.startTime.dateValue(), style: .time)
                }
                HStack {
                    Text("End Time")
                    Spacer()
                    Text(viewModel.incident.endTime.dateValue(), style: .time)
                }
            }

            Section("Client") {
                AddableClientCell(
                    selectedClientId: $viewModel.selectedClientId,
                    validClients: viewModel.clients,
                    onAddNewClient: {
                        // Clear the selection temporarily
                        viewModel.selectedClientId = nil
                        routerPath.push(.addClient(onClientCreated: { clientId in
                            Task {
                                await viewModel.handleNewClientCreated(clientId)
                            }
                        }))
                    },
                    onClientSelected: {
                        await viewModel.updateIncident()
                    },
                    onNavigateToClient: { client in
                        routerPath.push(.clientDetail(client: client))
                    }
                )
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Incident Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { routerPath.push(.editIncident(incident: viewModel.incident)) }
            }
        }
        .onAppear {
            Task { await viewModel.reloadIncident() }
        }
        .task {
            await viewModel.loadClient()
        }
        .refreshable {
            await viewModel.reloadIncident()
        }
        .onChange(of: viewModel.pickedBeforePhotos) { _, newPhotos in
            if !newPhotos.isEmpty {
                Task {
                    await viewModel.updateIncidentWithPhotos(beforePhotos: newPhotos, afterPhotos: [])
                    viewModel.pickedBeforePhotos.removeAll()
                }
            }
        }
        .onChange(of: viewModel.pickedAfterPhotos) { _, newPhotos in
            if !newPhotos.isEmpty {
                Task {
                    await viewModel.updateIncidentWithPhotos(beforePhotos: [], afterPhotos: newPhotos)
                    viewModel.pickedAfterPhotos.removeAll()
                }
            }
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
//        rate: 75.0,
//        materialsUsed: "Paint, brushes"
//    )
//    FreshWallPreview {
//        NavigationStack {
//            IncidentDetailView(incident: sampleIncident)
//        }
//    }
// }

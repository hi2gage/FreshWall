import FirebaseFirestore
import SwiftUI

/// A view displaying detailed information for a specific incident.
struct IncidentDetailView: View {
    @State private var incident: IncidentDTO
    let incidentService: IncidentServiceProtocol
    let clientService: ClientServiceProtocol
    @State private var showingEdit = false
    @State private var viewerSources: [PhotoSource] = []
    @State private var viewerIndex = 0
    @State private var showingViewer = false

    init(incident: IncidentDTO, incidentService: IncidentServiceProtocol, clientService: ClientServiceProtocol) {
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
    }

    var body: some View {
        List {
            Section("Overview") {
                Text(incident.description)
                HStack {
                    Text("Status")
                    Spacer()
                    Text(incident.status.capitalized)
                }
                if let project = incident.projectName {
                    HStack {
                        Text("Project")
                        Spacer()
                        Text(project)
                    }
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
            if let beforePhotos = incident.beforePhotoUrls.nullIfEmpty {
                Section("Before Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(beforePhotos.enumerated()), id: \.1) { idx, urlString in
                                AsyncImage(url: URL(string: urlString)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case let .success(image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .onTapGesture {
                                                viewerSources = beforePhotos.map { PhotoSource.url($0) }
                                                viewerIndex = idx
                                                showingViewer = true
                                            }
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 120)
                }
            }
            if let afterPhotoUrls = incident.afterPhotoUrls.nullIfEmpty {
                Section("After Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(afterPhotoUrls.enumerated()), id: \.1) { idx, urlString in
                                AsyncImage(url: URL(string: urlString)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case let .success(image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .onTapGesture {
                                                viewerSources = afterPhotoUrls.map { PhotoSource.url($0) }
                                                viewerIndex = idx
                                                showingViewer = true
                                            }
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 120)
                }
            }
//            Section("References") {
//                HStack {
//                    Text("Client Ref")
//                    Spacer()
//                    Text(incident.clientRef.documentID)
//                }
//                ForEach(incident.workerRefs, id: \.path) { ref in
//                    HStack {
//                        Text("Worker Ref")
//                        Spacer()
//                        Text(ref.documentID)
//                    }
//                }
//            }
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
        .fullScreenCover(isPresented: $showingViewer) {
            PhotoViewer(sources: viewerSources, index: $viewerIndex)
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
//        beforePhotoUrls: ["https://via.placeholder.com/100"],
//        afterPhotoUrls: ["https://via.placeholder.com/100"],
//        createdBy: dummyRef,
//        lastModifiedBy: nil,
//        lastModifiedAt: nil,
//        billable: true,
//        rate: 75.0,
//        projectName: "Front Wall Project",
//        status: "completed",
//        materialsUsed: "Paint, brushes"
//    )
//    FreshWallPreview {
//        NavigationStack {
//            IncidentDetailView(incident: sampleIncident)
//        }
//    }
// }

import SwiftUI
import FirebaseFirestore

/// A view displaying detailed information for a specific incident.
struct IncidentDetailView: View {
    let incident: Incident

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
                            ForEach(beforePhotos, id: \.self) { urlString in
                                AsyncImage(url: URL(string: urlString)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
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
                            ForEach(afterPhotoUrls, id: \.self) { urlString in
                                AsyncImage(url: URL(string: urlString)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
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
    }
}
//
//#Preview {
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
//}

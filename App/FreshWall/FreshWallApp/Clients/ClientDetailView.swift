import FirebaseFirestore
import SwiftUI

/// A view displaying detailed information for a specific client.
struct ClientDetailView: View {
    @State private var client: Client
    let incidentService: IncidentServiceProtocol
    let clientService: ClientServiceProtocol
    @Environment(RouterPath.self) private var routerPath
    @State private var incidents: [Incident] = []
    @State private var showingExportOptions = false
    @State private var showingDeleteConfirmation = false

    init(
        client: Client,
        incidentService: IncidentServiceProtocol,
        clientService: ClientServiceProtocol
    ) {
        _client = State(wrappedValue: client)
        self.incidentService = incidentService
        self.clientService = clientService
    }

    /// Reloads the client data after editing.
    private func reloadClient() async {
        guard let id = client.id else { return }

        let updatedClients = await (try? clientService.fetchClients()) ?? []
        if let updated = updatedClients.first(where: { $0.id == id }) {
            client = updated
        }
    }

    /// Exports an invoice PDF for billable incidents.
    private func exportInvoice() {
        let billableIncidents = incidents
        let reportPeriod = getCurrentMonthYear()

        let pdfData = PDFService.generateClientInvoice(
            client: client,
            incidents: billableIncidents,
            reportPeriod: reportPeriod
        )

        sharePDF(data: pdfData, filename: "\(client.name) Invoice \(reportPeriod)")
    }

    /// Exports a detailed incident tracking report PDF.
    private func exportDetailedReport() {
        let reportPeriod = getCurrentMonthYear()

        let pdfData = PDFService.generateIncidentReport(
            client: client,
            incidents: incidents,
            reportPeriod: reportPeriod
        )

        sharePDF(data: pdfData, filename: "\(client.name) Incident Report \(reportPeriod)")
    }

    /// Presents a share sheet for the PDF.
    private func sharePDF(data: Data, filename: String) {
        // Create a temporary URL for the PDF
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).pdf")

        do {
            try data.write(to: tempURL)

            // Present share sheet
            let activityViewController = UIActivityViewController(
                activityItems: [tempURL],
                applicationActivities: nil
            )

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(activityViewController, animated: true)
            }
        } catch {
            print("Error sharing PDF: \(error)")
        }
    }

    /// Gets the current month and year for report naming.
    private func getCurrentMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    /// Deletes the client.
    private func deleteClient() async {
        guard let id = client.id else { return }

        do {
            try await clientService.deleteClient(id)
            routerPath.pop()
        } catch {
            print("Failed to delete client: \(error)")
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
                    Text("Last Incident")
                    Spacer()
                    Text(client.lastIncidentAt.dateValue(), style: .date)
                }

                if let deletedAt = client.deletedAt {
                    HStack {
                        Text("Deleted At")
                        Spacer()
                        Text(deletedAt.dateValue(), style: .date)
                    }
                }
            }

            Section("Billing Defaults") {
                if let defaults = client.defaults {
                    HStack {
                        Text("Billing Method")
                        Spacer()
                        Text(defaults.billingMethod.displayName)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Minimum Billable Quantity")
                        Spacer()
                        Text("\(defaults.minimumBillableQuantity, specifier: "%.1f") \(defaults.billingMethod.unitLabel)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Amount Per Unit")
                        Spacer()
                        Text("$\(defaults.amountPerUnit, specifier: "%.2f") per \(defaults.billingMethod.unitLabel)")
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("No billing defaults configured")
                        .italic()
                        .foregroundColor(.secondary)
                }
            }

            Section(header: Text("Incidents (\(incidents.count))")) {
                if incidents.isEmpty {
                    Text("No incidents for this client.")
                        .italic()
                } else {
                    ForEach(incidents) { _ in
//                        Button(incident.id) {
//                            routerPath.push(.incidentDetail(incident: incident))
//                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Client Details")
        .task {
            let all = await (try? incidentService.fetchIncidents()) ?? []
            incidents = all.filter { $0.clientRef?.documentID == client.id }
        }
        .refreshable {
            await reloadClient()
            let all = await (try? incidentService.fetchIncidents()) ?? []
            incidents = all.filter { $0.clientRef?.documentID == client.id }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Client Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { routerPath.push(.editClient(client: client)) }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Export PDF") {
                    showingExportOptions = true
                }
                .disabled(incidents.isEmpty)
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Delete Client", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
        }
        .confirmationDialog("Export Options", isPresented: $showingExportOptions) {
            Button("Invoice (Billable Only)") {
                exportInvoice()
            }
            Button("Detailed Incident Report") {
                exportDetailedReport()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose the type of PDF report to generate for \(client.name)")
        }
        .alert("Delete Client", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await deleteClient()
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(client.name)'? This action cannot be undone.")
        }
        .onAppear {
            Task { await reloadClient() }
        }
    }
}

//
// #Preview {
//    let sampleClient = Client(
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

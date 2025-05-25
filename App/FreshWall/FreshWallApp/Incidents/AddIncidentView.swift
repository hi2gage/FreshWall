@preconcurrency import FirebaseFirestore
import SwiftUI

/// View for adding a new incident, injecting a service conforming to `IncidentServiceProtocol`.

struct AddIncidentView: View {
    @Environment(\.dismiss) private var dismiss
    let service: IncidentServiceProtocol
    @State private var clientId: String = ""
    @State private var description: String = ""
    @State private var areaText: String = ""
    @State private var startTime: Date = .init()
    @State private var endTime: Date = .init()
    @State private var billable: Bool = false
    @State private var rateText: String = ""
    @State private var projectName: String = ""
    @State private var status: String = "open"
    @State private var materialsUsed: String = ""
    private let statusOptions = ["open", "in_progress", "completed"]

    var body: some View {
        Form {
            Section(header: Text("Client ID")) {
                TextField("Client Document ID", text: $clientId)
                    .autocapitalization(.none)
            }
            Section(header: Text("Description")) {
                TextEditor(text: $description)
                    .frame(minHeight: 100)
            }
            Section(header: Text("Area (sq ft)")) {
                TextField("Area", text: $areaText)
                    .keyboardType(.decimalPad)
            }
            Section(header: Text("Timeframe")) {
                DatePicker("Start Time", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                DatePicker("End Time", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
            }
            Section {
                Toggle("Billable", isOn: $billable)
                if billable {
                    TextField("Rate", text: $rateText)
                        .keyboardType(.decimalPad)
                }
            }
            Section(header: Text("Project Name")) {
                TextField("Project Name", text: $projectName)
            }
            Section(header: Text("Status")) {
                Picker("Status", selection: $status) {
                    ForEach(statusOptions, id: \.self) { option in
                        Text(option.capitalized).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section(header: Text("Materials Used")) {
                TextEditor(text: $materialsUsed)
                    .frame(minHeight: 80)
            }
        }
        .navigationTitle("Add Incident")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        do {
                            let areaValue = Double(areaText) ?? 0
                            let rateValue = Double(rateText)
                            let input = AddIncidentInput(
                                clientId: clientId.trimmingCharacters(in: .whitespaces),
                                description: description,
                                area: areaValue,
                                startTime: startTime,
                                endTime: endTime,
                                billable: billable,
                                rate: rateValue,
                                projectName: projectName.isEmpty ? nil : projectName,
                                status: status,
                                materialsUsed: materialsUsed.isEmpty ? nil : materialsUsed
                            )
                            try await service.addIncident(input)
                            dismiss()
                        } catch {
                            // TODO: Handle error if desired
                        }
                    }
                }
                .disabled(
                    clientId.trimmingCharacters(in: .whitespaces).isEmpty ||
                        description.trimmingCharacters(in: .whitespaces).isEmpty
                )
            }
        }
    }
}

/// Dummy implementation of `IncidentServiceProtocol` for previews.
@MainActor
private class PreviewIncidentService: IncidentServiceProtocol {
    func fetchIncidents() async throws -> [Incident] { [] }
    func addIncident(_: Incident) async throws {}
    func addIncident(_: AddIncidentInput) async throws {}
}

#Preview {
    FreshWallPreview {
        NavigationStack {
            AddIncidentView(service: PreviewIncidentService())
        }
    }
}

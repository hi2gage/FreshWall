@preconcurrency import FirebaseFirestore
import SwiftUI

/// View for adding a new incident, injecting a service conforming to `IncidentServiceProtocol`.

struct AddIncidentView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: AddIncidentViewModel

    var body: some View {
        Form {
            Section(header: Text("Client ID")) {
                TextField("Client Document ID", text: $viewModel.clientId)
                    .autocapitalization(.none)
            }
            Section(header: Text("Description")) {
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 100)
            }
            Section(header: Text("Area (sq ft)")) {
                TextField("Area", text: $viewModel.areaText)
                    .keyboardType(.decimalPad)
            }
            Section(header: Text("Timeframe")) {
                DatePicker(
                    "Start Time",
                    selection: $viewModel.startTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                DatePicker(
                    "End Time",
                    selection: $viewModel.endTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            Section {
                Toggle("Billable", isOn: $viewModel.billable)
                if viewModel.billable {
                    TextField("Rate", text: $viewModel.rateText)
                        .keyboardType(.decimalPad)
                }
            }
            Section(header: Text("Project Name")) {
                TextField("Project Name", text: $viewModel.projectName)
            }
            Section(header: Text("Status")) {
                Picker("Status", selection: $viewModel.status) {
                    ForEach(viewModel.statusOptions, id: \.self) { option in
                        Text(option.capitalized).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section(header: Text("Materials Used")) {
                TextEditor(text: $viewModel.materialsUsed)
                    .frame(minHeight: 80)
            }
        }
        .navigationTitle("Add Incident")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        do {
                            try await viewModel.save()
                            dismiss()
                        } catch {
                            // Handle error if needed
                        }
                    }
                }
                .disabled(viewModel.isValid)
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
            AddIncidentView(viewModel: AddIncidentViewModel(service: PreviewIncidentService()))
        }
    }
}

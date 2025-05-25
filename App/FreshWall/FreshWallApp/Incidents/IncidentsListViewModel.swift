import Observation

/// ViewModel driving the IncidentsListView.
@Observable
final class IncidentsListViewModel {
    /// Array of incidents to display.
    var incidents: [Incident] = []
    private let service: IncidentService

    /// Initializes with an IncidentService.
    init(service: IncidentService) {
        self.service = service
    }

    /// Loads incidents from the service.
    func loadIncidents() async {
        await service.fetchIncidents()
        incidents = service.incidents
    }
}
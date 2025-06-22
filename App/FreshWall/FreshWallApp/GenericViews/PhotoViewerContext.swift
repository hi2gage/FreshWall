import Foundation

/// Selection information for ``PhotoViewer``.
struct PhotoViewerContext: Identifiable {
    var photos: [IncidentPhoto]
    var selectedPhoto: IncidentPhoto
    var id: String { selectedPhoto.id }
}

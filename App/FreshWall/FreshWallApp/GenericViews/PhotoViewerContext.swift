import Foundation

/// Selection information for ``PhotoViewer``.
struct PhotoViewerContext: Identifiable, Hashable {
    var photos: [IncidentPhoto]
    var selectedPhoto: IncidentPhoto
    var id: String { selectedPhoto.id }
}

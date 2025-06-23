@testable import FreshWall
import Testing

struct PhotoViewerTests {
    @Test func initialIndexReturnsZeroWhenNoSelection() {
        let photos = [
            IncidentPhoto(id: "1", url: "a", captureDate: nil, location: nil),
            IncidentPhoto(id: "2", url: "b", captureDate: nil, location: nil),
        ]
        #expect(PhotoViewer.initialIndex(photos: photos, selectedPhoto: nil) == 0)
    }

    @Test func initialIndexMatchesSelectedPhoto() {
        let photos = [
            IncidentPhoto(id: "1", url: "a", captureDate: nil, location: nil),
            IncidentPhoto(id: "2", url: "b", captureDate: nil, location: nil),
        ]
        #expect(PhotoViewer.initialIndex(photos: photos, selectedPhoto: photos[1]) == 1)
    }
}

@testable import FreshWall
import Testing

struct PhotoViewerContextTests {
    @Test func idMatchesSelectedPhoto() {
        let photos = [IncidentPhoto(id: "1", url: "a", captureDate: nil, location: nil)]
        let context = PhotoViewerContext(photos: photos, selectedPhoto: photos[0])
        #expect(context.id == photos[0].id)
    }
}

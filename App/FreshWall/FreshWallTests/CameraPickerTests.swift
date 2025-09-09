@testable import FreshWall
import Testing
import UIKit

struct CameraPickerTests {
    @Test func makeControllerUsesCamera() {
        let picker = CameraPicker { _ in }
        let context = CameraPicker.Context(coordinator: picker.makeCoordinator())
        let controller = picker.makeUIViewController(context: context)
        #expect(controller.sourceType == .camera)
    }

    @Test func coordinatorCallsCompletion() {
        var called = false
        let picker = CameraPicker { _ in called = true }
        let coordinator = picker.makeCoordinator()
        coordinator.imagePickerController(
            UIImagePickerController(),
            didFinishPickingMediaWithInfo: [.originalImage: UIImage()]
        )
        #expect(called)
    }
}

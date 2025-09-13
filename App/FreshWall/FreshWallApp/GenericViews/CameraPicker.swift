import SwiftUI
import UIKit

/// A camera capture view using `UIImagePickerController`.
struct CameraPicker: UIViewControllerRepresentable {
    /// Completion handler providing JPEG data for the captured image.
    var onImagePicked: (Data?) -> Void

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let parent: CameraPicker

        init(parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(
            _: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            defer { parent.onImagePicked(parent.extractData(from: info)) }
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            parent.onImagePicked(nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    private func extractData(from info: [UIImagePickerController.InfoKey: Any]) -> Data? {
        guard let image = info[.originalImage] as? UIImage else { return nil }

        // Simple JPEG conversion - location is passed separately now
        return image.jpegData(compressionQuality: 0.8)
    }
}

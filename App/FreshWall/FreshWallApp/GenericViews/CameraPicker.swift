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
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            // Get the original image and convert to JPEG
            guard let image = info[.originalImage] as? UIImage,
                  let jpeg = image.jpegData(compressionQuality: 0.9) else {
                picker.dismiss(animated: true) { self.parent.onImagePicked(nil) }
                return
            }

            // Camera Roll saving is now handled in AddIncidentViewModel
            picker.dismiss(animated: true) { self.parent.onImagePicked(jpeg) }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) { self.parent.onImagePicked(nil) }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}
}

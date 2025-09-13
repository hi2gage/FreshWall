import CoreLocation
import ImageIO
import SwiftUI
import UIKit

/// A camera capture view using `UIImagePickerController`.
struct CameraPicker: UIViewControllerRepresentable {
    /// Completion handler providing JPEG data for the captured image.
    var onImagePicked: (Data?) -> Void

    @State private var captureLocation: CLLocation?

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

        // Try to get current location for metadata
        Task {
            do {
                let manager = OneTimeLocationManager()
                let incidentLocation = try await manager.getCurrentLocation()
                await MainActor.run {
                    // Convert IncidentLocation to CLLocation
                    if let coordinates = incidentLocation.coordinates {
                        captureLocation = CLLocation(
                            latitude: coordinates.latitude,
                            longitude: coordinates.longitude
                        )
                    }
                }
            } catch {
                // Location capture failed, continue without location
            }
        }

        return picker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    private func extractData(from info: [UIImagePickerController.InfoKey: Any]) -> Data? {
        guard let image = info[.originalImage] as? UIImage else { return nil }

        // For camera photos, we need to add current timestamp and location metadata
        // since UIImagePickerController doesn't preserve them automatically
        let jpegData = image.jpegData(compressionQuality: 0.8) ?? Data()

        return addCameraMetadata(to: jpegData)
    }

    private func addCameraMetadata(to imageData: Data) -> Data? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let type = CGImageSourceGetType(source) else { return imageData }

        let mutableData = NSMutableData(data: imageData)

        guard let destination = CGImageDestinationCreateWithData(mutableData, type, 1, nil) else {
            return imageData
        }

        // Add current timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        let currentTimeString = dateFormatter.string(from: Date())

        // Create EXIF metadata with timestamp
        let exifDict: [String: Any] = [
            kCGImagePropertyExifDateTimeOriginal as String: currentTimeString,
            kCGImagePropertyExifDateTimeDigitized as String: currentTimeString,
        ]

        let tiffDict: [String: Any] = [
            kCGImagePropertyTIFFDateTime as String: currentTimeString,
        ]

        // Start with base metadata
        var metadata: [String: Any] = [
            kCGImagePropertyExifDictionary as String: exifDict,
            kCGImagePropertyTIFFDictionary as String: tiffDict,
        ]

        // Add GPS metadata if location is available
        if let location = captureLocation {
            let gpsDict: [String: Any] = [
                kCGImagePropertyGPSLatitude as String: abs(location.coordinate.latitude),
                kCGImagePropertyGPSLatitudeRef as String: location.coordinate.latitude >= 0 ? "N" : "S",
                kCGImagePropertyGPSLongitude as String: abs(location.coordinate.longitude),
                kCGImagePropertyGPSLongitudeRef as String: location.coordinate.longitude >= 0 ? "E" : "W",
                kCGImagePropertyGPSTimeStamp as String: currentTimeString,
            ]
            metadata[kCGImagePropertyGPSDictionary as String] = gpsDict
        }

        // Add the image with metadata
        if let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) {
            CGImageDestinationAddImage(destination, cgImage, metadata as CFDictionary)
        }

        guard CGImageDestinationFinalize(destination) else { return imageData }

        return mutableData as Data
    }
}

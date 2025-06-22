import _PhotosUI_SwiftUI
import CoreLocation
import ImageIO
import Photos
import PhotosUI

/// Metadata extracted from an image.
struct PhotoMetadata: Sendable {
    /// Date the photo was captured if available.
    let captureDate: Date?
    /// Location the photo was captured if available.
    let location: CLLocation?
}

/// Protocol for loading metadata from selected photos.
protocol PhotoMetadataServiceProtocol: Sendable {
    /// Extract metadata from a picker item.
    func metadata(for item: PhotosPickerItem) async throws -> PhotoMetadata
    /// Extract metadata from raw image data.
    func metadata(from data: Data) -> PhotoMetadata
}

/// Default metadata service using `Photos` and `ImageIO`.
struct PhotoMetadataService: PhotoMetadataServiceProtocol {
    func metadata(for item: PhotosPickerItem) async throws -> PhotoMetadata {
        if let id = item.itemIdentifier {
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
            if let asset = assets.firstObject {
                return PhotoMetadata(captureDate: asset.creationDate, location: asset.location)
            }
        }
        if let data = try? await item.loadTransferable(type: Data.self) {
            return metadata(from: data)
        }
        return PhotoMetadata(captureDate: nil, location: nil)
    }

    func metadata(from data: Data) -> PhotoMetadata {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        else {
            return PhotoMetadata(captureDate: nil, location: nil)
        }

        var date: Date?
        if let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any],
           let dateString = exif[kCGImagePropertyExifDateTimeOriginal] as? String
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            date = formatter.date(from: dateString)
        } else if let tiff = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any],
                  let dateString = tiff[kCGImagePropertyTIFFDateTime] as? String
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            date = formatter.date(from: dateString)
        }

        var location: CLLocation?
        if let gps = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any],
           let lat = gps[kCGImagePropertyGPSLatitude] as? Double,
           let latRef = gps[kCGImagePropertyGPSLatitudeRef] as? String,
           let lon = gps[kCGImagePropertyGPSLongitude] as? Double,
           let lonRef = gps[kCGImagePropertyGPSLongitudeRef] as? String
        {
            let latitude = latRef == "S" ? -lat : lat
            let longitude = lonRef == "W" ? -lon : lon
            location = CLLocation(latitude: latitude, longitude: longitude)
        }

        return PhotoMetadata(captureDate: date, location: location)
    }
}

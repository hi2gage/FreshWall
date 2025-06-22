import _PhotosUI_SwiftUI
@testable import FreshWall
import Testing
import UniformTypeIdentifiers

struct PhotoPickerTests {
    private func makeTestImageData() -> Data {
        let width = 1
        let height = 1
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        var pixel: [UInt8] = [255, 0, 0, 255]
        let provider = CGDataProvider(data: Data(pixel) as CFData)!
        let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )!

        let metaData = NSMutableData()
        let dest = CGImageDestinationCreateWithData(metaData, UTType.jpeg.identifier as CFString, 1, nil)!
        let exif: [CFString: Any] = [kCGImagePropertyExifDateTimeOriginal: "2023:12:31 10:00:00"]
        CGImageDestinationAddImage(dest, cgImage, [kCGImagePropertyExifDictionary: exif] as CFDictionary)
        CGImageDestinationFinalize(dest)
        return metaData as Data
    }

    final actor MockMeta: PhotoMetadataServiceProtocol {
        func metadata(for _: PhotosPickerItem) async throws -> PhotoMetadata { PhotoMetadata(captureDate: .distantPast, location: nil) }
        func metadata(from _: Data) -> PhotoMetadata { PhotoMetadata(captureDate: .distantPast, location: nil) }
    }

    @Test func createPickedPhotoFromData() {
        let data = makeTestImageData()
        let photo = PickedPhoto.make(from: data, using: MockMeta())
        #expect(photo?.captureDate == .distantPast)
        #expect(photo?.image.size.width == 1)
    }

    @Test func convertPhotosToDTOs() {
        let renderer = UIGraphicsImageRenderer(size: .init(width: 1, height: 1))
        let image = renderer.image { _ in }
        let photo = PickedPhoto(image: image, captureDate: .distantPast, location: CLLocation(latitude: 1, longitude: 2))
        let dtos = [photo].toIncidentPhotoDTOs(urls: ["url"])
        #expect(dtos.first?.url == "url")
        #expect(dtos.first?.captureDate?.dateValue() == .distantPast)
        #expect(dtos.first?.location?.latitude == 1)
        #expect(dtos.first?.location?.longitude == 2)
    }
}

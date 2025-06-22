import CoreLocation
@testable import FreshWall
import Testing
import UniformTypeIdentifiers

struct PhotoMetadataServiceTests {
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
        let gps: [CFString: Any] = [
            kCGImagePropertyGPSLatitude: 37.0,
            kCGImagePropertyGPSLatitudeRef: "N",
            kCGImagePropertyGPSLongitude: 122.0,
            kCGImagePropertyGPSLongitudeRef: "W",
        ]
        let props: [CFString: Any] = [
            kCGImagePropertyExifDictionary: exif,
            kCGImagePropertyGPSDictionary: gps,
        ]
        CGImageDestinationAddImage(dest, cgImage, props as CFDictionary)
        CGImageDestinationFinalize(dest)
        return metaData as Data
    }

    @Test func parseMetadataFromData() {
        let data = makeTestImageData()
        let service = PhotoMetadataService()
        let meta = service.metadata(from: data)
        #expect(meta.location?.coordinate.latitude == 37.0)
        #expect(meta.location?.coordinate.longitude == -122.0)
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: meta.captureDate ?? .distantPast)
        #expect(comps.year == 2023)
        #expect(comps.month == 12)
        #expect(comps.day == 31)
        #expect(comps.hour == 10)
        #expect(comps.minute == 0)
    }
}

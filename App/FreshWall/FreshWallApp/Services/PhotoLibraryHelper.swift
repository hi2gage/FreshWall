import CoreLocation
import Foundation
import Photos
import UniformTypeIdentifiers

/// Helper class for saving photos to the device's Photo Library
enum PhotoLibraryHelper {
    /// Album name for organizing FreshWall photos
    private static let albumTitle = "FreshWall"

    /// Saves photos to Camera Roll with location metadata in a dedicated FreshWall album
    static func savePhotosToLibrary(
        beforePhotos: [PickedPhoto],
        afterPhotos: [PickedPhoto],
        location: IncidentLocation?
    ) async {
        let allPhotos = beforePhotos + afterPhotos
        guard !allPhotos.isEmpty else { return }

        print("📸 Saving \(allPhotos.count) photos to Camera Roll with location: \(location?.coordinates != nil)")

        // Convert IncidentLocation to CLLocation if coordinates available
        let clLocation: CLLocation? = {
            guard let coordinates = location?.coordinates else { return nil }

            return CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        }()

        // Save all photos in parallel using TaskGroup for better performance
        await withTaskGroup(of: Void.self) { group in
            for (index, photo) in allPhotos.enumerated() {
                group.addTask {
                    await saveSinglePhoto(photo: photo, index: index + 1, totalCount: allPhotos.count, location: clLocation)
                }
            }
        }
        print("✅ All \(allPhotos.count) photos saved to Camera Roll")
    }

    /// Saves a single photo to the library
    private static func saveSinglePhoto(photo: PickedPhoto, index: Int, totalCount: Int, location: CLLocation?) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                guard let imageData = photo.image.jpegData(compressionQuality: 0.9) else {
                    print("❌ Failed to convert image \(index) to JPEG")
                    continuation.resume()
                    return
                }

                PHPhotoLibrary.shared().performChanges({
                    // Create the asset first
                    let assetRequest = PHAssetCreationRequest.forAsset()
                    assetRequest.creationDate = Date()
                    assetRequest.location = location

                    let opts = PHAssetResourceCreationOptions()
                    opts.uniformTypeIdentifier = UTType.jpeg.identifier
                    assetRequest.addResource(with: .photo, data: imageData, options: opts)

                    // Find or create FreshWall album
                    let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
                    var freshWallAlbum: PHAssetCollection?

                    // Look for existing FreshWall album
                    collections.enumerateObjects { collection, _, _ in
                        if collection.localizedTitle == albumTitle {
                            freshWallAlbum = collection
                        }
                    }

                    // Create album if it doesn't exist, or add to existing one
                    if freshWallAlbum == nil {
                        let albumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumTitle)
                        if let placeholderAsset = assetRequest.placeholderForCreatedAsset {
                            albumRequest.addAssets([placeholderAsset] as NSArray)
                        }
                    } else {
                        // Add to existing album
                        if let album = freshWallAlbum,
                           let placeholderAsset = assetRequest.placeholderForCreatedAsset,
                           let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                            albumChangeRequest.addAssets([placeholderAsset] as NSArray)
                        }
                    }
                }) { success, error in
                    if success {
                        print("✅ Photo \(index)/\(totalCount) saved to Camera Roll with location: \(location != nil)")
                    } else {
                        print("❌ Failed to save photo \(index): \(error?.localizedDescription ?? "unknown")")
                    }
                    continuation.resume()
                }
            }
        }
    }
}

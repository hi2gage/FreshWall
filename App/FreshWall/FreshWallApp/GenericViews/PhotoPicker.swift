import _PhotosUI_SwiftUI
import CoreLocation
import PhotosUI
import SwiftUI

// MARK: - PickedPhoto

/// A photo selected from ``PhotoPicker`` along with optional metadata.
struct PickedPhoto: Identifiable, Sendable, Equatable {
    /// Unique identifier for the selection.
    let id: String
    /// Chosen image.
    let image: UIImage
    /// Date when the photo was captured, if available.
    let captureDate: Date?
    /// Location where the photo was captured, if available.
    let location: CLLocation?
    /// Resolved address for the location, if available (from camera).
    let resolvedAddress: String?

    /// Create a ``PickedPhoto`` from raw image data using a metadata service.
    /// - Parameters:
    ///   - data: Raw image bytes.
    ///   - service: Service used to extract metadata.
    /// - Returns: A ``PickedPhoto`` if the data can be converted to an image.
    init(id: String, image: UIImage, captureDate: Date?, location: CLLocation?, resolvedAddress: String? = nil) {
        self.id = id
        self.image = image
        self.captureDate = captureDate
        self.location = location
        self.resolvedAddress = resolvedAddress
    }

    static func make(
        id: String,
        from data: Data,
        using service: PhotoMetadataServiceProtocol
    ) -> PickedPhoto? {
        guard let image = UIImage(data: data) else { return nil }

        let meta = service.metadata(from: data)
        return PickedPhoto(
            id: id,
            image: image,
            captureDate: meta.captureDate,
            location: meta.location,
            resolvedAddress: nil
        )
    }
}

// MARK: - PhotoPicker

/// A wrapper around ``PhotosPicker`` that loads selected images and their metadata.
struct PhotoPicker<Label: View>: View {
    @Binding private var selection: [PickedPhoto]
    private let metadataService: PhotoMetadataServiceProtocol

    private var maxSelectionCount: Int?
    private var selectionBehavior: PhotosPickerSelectionBehavior
    private var filter: PHPickerFilter?
    private var preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy
    private var photoLibrary: PHPhotoLibrary
    private let label: () -> Label

    @State private var items: [PhotosPickerItem] = []

    init(
        selection: Binding<[PickedPhoto]>,
        maxSelectionCount: Int? = nil,
        selectionBehavior: PhotosPickerSelectionBehavior = .default,
        matching filter: PHPickerFilter? = nil,
        preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy = .automatic,
        photoLibrary: PHPhotoLibrary,
        metadataService: PhotoMetadataServiceProtocol = PhotoMetadataService(),
        @ViewBuilder label: @escaping () -> Label
    ) {
        _selection = selection
        self.maxSelectionCount = maxSelectionCount
        self.selectionBehavior = selectionBehavior
        self.filter = filter
        self.preferredItemEncoding = preferredItemEncoding
        self.photoLibrary = photoLibrary
        self.metadataService = metadataService
        self.label = label
    }

    var body: some View {
        PhotosPicker(
            selection: $items,
            maxSelectionCount: maxSelectionCount,
            selectionBehavior: selectionBehavior,
            matching: filter,
            preferredItemEncoding: preferredItemEncoding,
            photoLibrary: photoLibrary,
            label: label
        )
        .onChange(of: items) { _, newItems in
            Task {
                var newSelection: [PickedPhoto] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let photo = PickedPhoto.make(
                           id: item.itemIdentifier ?? UUID().uuidString,
                           from: data,
                           using: metadataService
                       ) {
                        newSelection.append(photo)
                    }
                }
                selection = newSelection
            }
        }
    }
}

#Preview {
    @State var photos: [PickedPhoto] = []

    return FreshWallPreview {
        VStack {
            PhotoPicker(selection: $photos, photoLibrary: .shared()) {
                Label("Select Photos", systemImage: "photo")
            }
            Text("Selected: \(photos.count)")
        }
    }
}

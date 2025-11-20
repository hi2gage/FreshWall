import PhotosUI
import SwiftUI

/// A button that presents a menu allowing the user to choose the camera or the photo library.
struct PhotoSourcePicker<Label: View>: View {
    @Binding private var selection: [PickedPhoto]
    private let metadataService: PhotoMetadataServiceProtocol
    private let maxSelectionCount: Int?
    private let selectionBehavior: PhotosPickerSelectionBehavior
    private let filter: PHPickerFilter?
    private let preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy
    private let photoLibrary: PHPhotoLibrary
    private let onCameraSelected: (() -> Void)?
    private let label: () -> Label

    @State private var showDialog = false
    @State private var showCamera = false
    @State private var libraryItems: [PhotosPickerItem] = []
    @State private var showLibrary = false
    @State private var isProcessingPhotos = false

    init(
        selection: Binding<[PickedPhoto]>,
        maxSelectionCount: Int? = nil,
        selectionBehavior: PhotosPickerSelectionBehavior = .default,
        matching filter: PHPickerFilter? = nil,
        preferredItemEncoding: PhotosPickerItem.EncodingDisambiguationPolicy = .automatic,
        photoLibrary: PHPhotoLibrary,
        metadataService: PhotoMetadataServiceProtocol = PhotoMetadataService(),
        onCameraSelected: (() -> Void)? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) {
        _selection = selection
        self.maxSelectionCount = maxSelectionCount
        self.selectionBehavior = selectionBehavior
        self.filter = filter
        self.preferredItemEncoding = preferredItemEncoding
        self.photoLibrary = photoLibrary
        self.metadataService = metadataService
        self.onCameraSelected = onCameraSelected
        self.label = label
    }

    var body: some View {
        Button(action: { showDialog = true }, label: label)
            .confirmationDialog("Add Photo", isPresented: $showDialog) {
                Button("Camera") {
                    onCameraSelected?()
                    showCamera = true
                }
                Button("Photo Library") { showLibrary = true }
                Button("Cancel", role: .cancel) {}
            }
            .photosPicker(
                isPresented: $showLibrary,
                selection: $libraryItems,
                maxSelectionCount: maxSelectionCount,
                selectionBehavior: selectionBehavior,
                matching: filter,
                preferredItemEncoding: preferredItemEncoding,
                photoLibrary: photoLibrary
            )
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { data in
                    if let data, let image = UIImage(data: data) {
                        // Create PickedPhoto without location (will be handled in AddIncidentView)
                        let photo = PickedPhoto(
                            id: UUID().uuidString,
                            image: image,
                            captureDate: Date(), // Camera photos taken now
                            location: nil,
                            resolvedAddress: nil
                        )

                        // Camera photos always get unique IDs, so no deduplication needed
                        print("✅ PhotoSourcePicker: Adding camera photo")
                        selection.append(photo)
                    }
                    showCamera = false
                }
                .ignoresSafeArea()
            }
            .onChange(of: libraryItems) { oldItems, newItems in
                // Only process if we have new items and they're different from old items
                guard !newItems.isEmpty, newItems != oldItems else { return }

                // Prevent concurrent processing
                guard !isProcessingPhotos else {
                    print("⚠️ PhotoSourcePicker: Already processing photos, ignoring duplicate onChange")
                    return
                }

                isProcessingPhotos = true

                Task {
                    defer { isProcessingPhotos = false }

                    var newPhotos: [PickedPhoto] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let photo = PickedPhoto.make(
                               id: item.itemIdentifier ?? UUID().uuidString,
                               from: data,
                               using: metadataService
                           ) {
                            // Deduplicate: only add if this ID doesn't already exist in selection
                            if !selection.contains(where: { $0.id == photo.id }) {
                                newPhotos.append(photo)
                            } else {
                                print("⚠️ PhotoSourcePicker: Skipping duplicate photo with ID: \(photo.id)")
                            }
                        }
                    }

                    if !newPhotos.isEmpty {
                        print("✅ PhotoSourcePicker: Adding \(newPhotos.count) new photo(s)")
                        selection.append(contentsOf: newPhotos)
                    }

                    libraryItems.removeAll()
                }
            }
    }
}

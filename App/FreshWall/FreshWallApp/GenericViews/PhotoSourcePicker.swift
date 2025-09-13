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

                        selection.append(photo)
                    }
                    showCamera = false
                }
                .ignoresSafeArea()
            }
            .onChange(of: libraryItems) { _, newItems in
                Task {
                    var newPhotos: [PickedPhoto] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let photo = PickedPhoto.make(
                               id: item.itemIdentifier ?? UUID().uuidString,
                               from: data,
                               using: metadataService
                           ) {
                            newPhotos.append(photo)
                        }
                    }
                    selection.append(contentsOf: newPhotos)
                    libraryItems.removeAll()
                }
            }
    }
}

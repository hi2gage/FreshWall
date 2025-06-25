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
    private let label: () -> Label

    @State private var showDialog = false
    @State private var showCamera = false
    @State private var librarySelection: [PickedPhoto] = []

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
        Button(action: { showDialog = true }, label: label)
            .confirmationDialog("Add Photo", isPresented: $showDialog) {
                Button("Camera") { showCamera = true }
                PhotoPicker(
                    selection: $librarySelection,
                    maxSelectionCount: maxSelectionCount,
                    selectionBehavior: selectionBehavior,
                    matching: filter,
                    preferredItemEncoding: preferredItemEncoding,
                    photoLibrary: photoLibrary,
                    metadataService: metadataService
                ) {
                    Text("Photo Library")
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker { data in
                    if let data,
                       let photo = PickedPhoto.make(
                           id: UUID().uuidString,
                           from: data,
                           using: metadataService
                       ) {
                        selection.append(photo)
                    }
                    showCamera = false
                }
            }
            .onChange(of: librarySelection) { _, newValue in
                selection.append(contentsOf: newValue)
                librarySelection.removeAll()
            }
    }
}


import PhotosUI
import SwiftUI

// MARK: - EditablePhotosSection

/// Photos section for editing incidents with photo deletion support
struct EditablePhotosSection: View {
    let beforePhotos: [EditablePhoto]
    let afterPhotos: [EditablePhoto]
    @Binding var newBeforePhotos: [PickedPhoto]
    @Binding var newAfterPhotos: [PickedPhoto]
    let onDeletePhoto: (EditablePhoto, Bool) -> Void
    let onPhotosChanged: (() -> Void)?
    let onCameraSelected: (() -> Void)?

    init(
        beforePhotos: [EditablePhoto],
        afterPhotos: [EditablePhoto],
        newBeforePhotos: Binding<[PickedPhoto]>,
        newAfterPhotos: Binding<[PickedPhoto]>,
        onDeletePhoto: @escaping (EditablePhoto, Bool) -> Void,
        onPhotosChanged: (() -> Void)? = nil,
        onCameraSelected: (() -> Void)? = nil
    ) {
        self.beforePhotos = beforePhotos
        self.afterPhotos = afterPhotos
        self._newBeforePhotos = newBeforePhotos
        self._newAfterPhotos = newAfterPhotos
        self.onDeletePhoto = onDeletePhoto
        self.onPhotosChanged = onPhotosChanged
        self.onCameraSelected = onCameraSelected
    }

    var body: some View {
        // Display existing and new before photos
        if !beforePhotos.isEmpty {
            Section("Before Photos") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(beforePhotos) { photo in
                            EditablePhotoView(photo: photo) {
                                onDeletePhoto(photo, true)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(height: 130)
            }
        }

        // Photo picker for before photos
        PhotoSourcePicker(
            selection: $newBeforePhotos,
            matching: .images,
            photoLibrary: .shared(),
            onCameraSelected: onCameraSelected
        ) {
            Label("Add Before Photos", systemImage: "photo.on.rectangle")
        }
        .onChange(of: newBeforePhotos) { _, _ in
            onPhotosChanged?()
        }

        // Display existing and new after photos
        if !afterPhotos.isEmpty {
            Section("After Photos") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(afterPhotos) { photo in
                            EditablePhotoView(photo: photo) {
                                onDeletePhoto(photo, false)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(height: 130)
            }
        }

        // Photo picker for after photos
        PhotoSourcePicker(
            selection: $newAfterPhotos,
            matching: .images,
            photoLibrary: .shared(),
            onCameraSelected: onCameraSelected
        ) {
            Label("Add After Photos", systemImage: "photo.fill.on.rectangle.fill")
        }
        .onChange(of: newAfterPhotos) { _, _ in
            onPhotosChanged?()
        }
    }
}

// MARK: - EditablePhotoView

/// View for displaying a single editable photo with delete button
struct EditablePhotoView: View {
    let photo: EditablePhoto
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Photo content
            Group {
                switch photo {
                case let .existing(incidentPhoto):
                    AsyncImage(url: URL(string: incidentPhoto.thumbnailUrl ?? incidentPhoto.url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case let .success(image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                case let .picked(pickedPhoto):
                    Image(uiImage: pickedPhoto.image)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 100, height: 100)
            .clipped()
            .cornerRadius(8)

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.red))
                    .font(.title3)
            }
            .offset(x: 8, y: -8)
        }
    }
}

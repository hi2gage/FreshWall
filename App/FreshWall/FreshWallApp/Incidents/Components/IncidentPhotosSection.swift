import PhotosUI
import SwiftUI

// MARK: - IncidentPhotosSection

/// Photos section with before and after photo pickers for incident forms
struct IncidentPhotosSection: View {
    @Binding var beforePhotos: [PickedPhoto]
    @Binding var afterPhotos: [PickedPhoto]
    let onPhotosChanged: (() -> Void)?
    let onCameraSelected: (() -> Void)?
    let onDeletePhoto: ((PickedPhoto, Bool) -> Void)? // photo, isBeforePhoto

    init(
        beforePhotos: Binding<[PickedPhoto]>,
        afterPhotos: Binding<[PickedPhoto]>,
        onPhotosChanged: (() -> Void)? = nil,
        onCameraSelected: (() -> Void)? = nil,
        onDeletePhoto: ((PickedPhoto, Bool) -> Void)? = nil
    ) {
        self._beforePhotos = beforePhotos
        self._afterPhotos = afterPhotos
        self.onPhotosChanged = onPhotosChanged
        self.onCameraSelected = onCameraSelected
        self.onDeletePhoto = onDeletePhoto
    }

    var body: some View {
        if !beforePhotos.isEmpty {
            Section("Before Photos") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(beforePhotos.indices, id: \.self) { idx in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: beforePhotos[idx].image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(8)

                                if onDeletePhoto != nil {
                                    Button(action: {
                                        onDeletePhoto?(beforePhotos[idx], true)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Circle().fill(Color.red))
                                            .font(.title3)
                                    }
                                    .offset(x: 8, y: -8)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(height: 130)
            }
        }

        PhotoSourcePicker(
            selection: $beforePhotos,
            matching: .images,
            photoLibrary: .shared(),
            onCameraSelected: onCameraSelected
        ) {
            Label("Add Before Photos", systemImage: "photo.on.rectangle")
        }
        .onChange(of: beforePhotos) { _, _ in
            onPhotosChanged?()
        }

        if !afterPhotos.isEmpty {
            Section("After Photos") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(afterPhotos.indices, id: \.self) { idx in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: afterPhotos[idx].image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .cornerRadius(8)

                                if onDeletePhoto != nil {
                                    Button(action: {
                                        onDeletePhoto?(afterPhotos[idx], false)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Circle().fill(Color.red))
                                            .font(.title3)
                                    }
                                    .offset(x: 8, y: -8)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(height: 130)
            }
        }

        PhotoSourcePicker(
            selection: $afterPhotos,
            matching: .images,
            photoLibrary: .shared(),
            onCameraSelected: onCameraSelected
        ) {
            Label("Add After Photos", systemImage: "photo.fill.on.rectangle.fill")
        }
        .onChange(of: afterPhotos) { _, _ in
            onPhotosChanged?()
        }
    }
}

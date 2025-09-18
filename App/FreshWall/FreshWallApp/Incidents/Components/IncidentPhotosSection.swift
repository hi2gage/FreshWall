import PhotosUI
import SwiftUI

// MARK: - IncidentPhotosSection

/// Photos section with before and after photo pickers for incident forms
struct IncidentPhotosSection: View {
    @Binding var beforePhotos: [PickedPhoto]
    @Binding var afterPhotos: [PickedPhoto]
    let onPhotosChanged: (() -> Void)?
    let onCameraSelected: (() -> Void)?

    init(
        beforePhotos: Binding<[PickedPhoto]>,
        afterPhotos: Binding<[PickedPhoto]>,
        onPhotosChanged: (() -> Void)? = nil,
        onCameraSelected: (() -> Void)? = nil
    ) {
        self._beforePhotos = beforePhotos
        self._afterPhotos = afterPhotos
        self.onPhotosChanged = onPhotosChanged
        self.onCameraSelected = onCameraSelected
    }

    var body: some View {
        if !beforePhotos.isEmpty {
            Section("Before Photos") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(beforePhotos.indices, id: \.self) { idx in
                            Image(uiImage: beforePhotos[idx].image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                        }
                    }
                }
                .frame(height: 120)
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
                    HStack {
                        ForEach(afterPhotos.indices, id: \.self) { idx in
                            Image(uiImage: afterPhotos[idx].image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                        }
                    }
                }
                .frame(height: 120)
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

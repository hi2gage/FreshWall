@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
import Foundation

// @Observable
actor BackgroundUploadService {
    static let shared = BackgroundUploadService()

    struct UploadTask {
        let id = UUID()
        let incidentId: String
        let teamId: String
        let photos: [PickedPhoto]
        let isBeforePhotos: Bool
        var progress: Double = 0.0
        var isCompleted = false
        var error: Error?
    }

    private var uploadTasks: [UUID: UploadTask] = [:]
    private var photoService: IncidentPhotoServiceProtocol
    private var modelService: IncidentModelServiceProtocol
    private var userModelService: UserModelServiceProtocol

    private init(
        photoService: IncidentPhotoServiceProtocol = IncidentPhotoService(),
        modelService: IncidentModelServiceProtocol = IncidentModelService(
            firestore: Firestore.firestore()
        ),
        userModelService: UserModelServiceProtocol = UserModelService(
            firestore: Firestore.firestore()
        )
    ) {
        self.photoService = photoService
        self.modelService = modelService
        self.userModelService = userModelService
    }

    var activeUploads: [UploadTask] {
        Array(uploadTasks.values.filter { !$0.isCompleted })
    }

    var hasActiveUploads: Bool {
        !activeUploads.isEmpty
    }

    func startUpload(
        incidentId: String,
        teamId: String,
        beforePhotos: [PickedPhoto],
        afterPhotos: [PickedPhoto]
    ) {
        print("🚀 BackgroundUploadService: Starting upload for incident \(incidentId)")
        print("📸 Before photos: \(beforePhotos.count), After photos: \(afterPhotos.count)")

        if !beforePhotos.isEmpty {
            let beforeTask = UploadTask(
                incidentId: incidentId,
                teamId: teamId,
                photos: beforePhotos,
                isBeforePhotos: true
            )
            uploadTasks[beforeTask.id] = beforeTask
            print("📝 Created before photos task: \(beforeTask.id)")

            Task {
                await uploadPhotos(taskId: beforeTask.id)
            }
        }

        if !afterPhotos.isEmpty {
            let afterTask = UploadTask(
                incidentId: incidentId,
                teamId: teamId,
                photos: afterPhotos,
                isBeforePhotos: false
            )
            uploadTasks[afterTask.id] = afterTask
            print("📝 Created after photos task: \(afterTask.id)")

            Task {
                await uploadPhotos(taskId: afterTask.id)
            }
        }
    }

    private func uploadPhotos(taskId: UUID) async {
        guard var task = uploadTasks[taskId] else {
            print("❌ Upload task \(taskId) not found")
            return
        }

        print("⏳ Starting upload for task \(taskId) - \(task.isBeforePhotos ? "before" : "after") photos")

        do {
            let imageData = task.photos.compactMap { $0.image.jpegData(compressionQuality: 0.8) }
            print("📱 Converted \(imageData.count) images to data")

            let urls: [String]
            if task.isBeforePhotos {
                print("📤 Uploading before photos...")
                urls = try await photoService.uploadBeforePhotos(
                    teamId: task.teamId,
                    incidentId: task.incidentId,
                    images: imageData
                )
            } else {
                print("📤 Uploading after photos...")
                urls = try await photoService.uploadAfterPhotos(
                    teamId: task.teamId,
                    incidentId: task.incidentId,
                    images: imageData
                )
            }

            print("✅ Photos uploaded successfully. URLs: \(urls)")
            await updateProgress(taskId: taskId, progress: 0.8)

            let photoDTOs = task.photos.toIncidentPhotoDTOs(urls: urls)
            let fieldName = task.isBeforePhotos ? "beforePhotos" : "afterPhotos"
            let photoDicts = photoDTOs.map(\.dictionary)

            let uid = Auth.auth().currentUser?.uid ?? ""
            let modifiedByRef = userModelService.userDocument(teamId: task.teamId, userId: uid)

            let data: [String: Any] = [
                fieldName: FieldValue.arrayUnion(photoDicts),
                "lastModifiedAt": FieldValue.serverTimestamp(),
                "lastModifiedBy": modifiedByRef,
            ]

            print("💾 Updating incident \(task.incidentId) with \(fieldName)")
            print("🔐 User: \(uid)")

            try await modelService.updateIncident(
                id: task.incidentId,
                teamId: task.teamId,
                data: data
            )

            print("✅ Incident updated successfully")
            await completeUpload(taskId: taskId)

        } catch {
            print("❌ Upload failed for task \(taskId): \(error)")
            await failUpload(taskId: taskId, error: error)
        }
    }

    private func updateProgress(taskId: UUID, progress: Double) {
        uploadTasks[taskId]?.progress = progress
    }

    private func completeUpload(taskId: UUID) {
        uploadTasks[taskId]?.isCompleted = true
        uploadTasks[taskId]?.progress = 1.0

        Task {
            try? await Task.sleep(for: .seconds(2))
            uploadTasks.removeValue(forKey: taskId)
        }
    }

    private func failUpload(taskId: UUID, error: Error) {
        uploadTasks[taskId]?.error = error
        uploadTasks[taskId]?.isCompleted = true
        print("Upload failed for task \(taskId): \(error.localizedDescription)")
    }

    func retryFailedUpload(taskId: UUID) {
        guard var task = uploadTasks[taskId], task.error != nil else { return }

        task.error = nil
        task.progress = 0.0
        task.isCompleted = false
        uploadTasks[taskId] = task

        Task {
            await uploadPhotos(taskId: taskId)
        }
    }

    func cancelUpload(taskId: UUID) {
        uploadTasks.removeValue(forKey: taskId)
    }
}

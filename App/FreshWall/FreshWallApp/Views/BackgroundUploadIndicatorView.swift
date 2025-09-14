import SwiftUI

// MARK: - BackgroundUploadIndicatorView

struct BackgroundUploadIndicatorView: View {
    @State private var isExpanded = false
    @State private var activeUploads: [BackgroundUploadService.UploadTask] = []
    @State private var hasActiveUploads = false
    @State private var timer: Timer?

    var body: some View {
        VStack {
            if hasActiveUploads {
                VStack {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.blue)

                        Text("Uploading \(activeUploads.count) photo\(activeUploads.count == 1 ? "" : "s")...")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Button(action: { isExpanded.toggle() }) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    if isExpanded {
                        VStack(spacing: 4) {
                            ForEach(activeUploads, id: \.id) { task in
                                UploadTaskRowView(task: task)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
                .animation(.easeInOut(duration: 0.3), value: isExpanded)
            }
        }
        .onAppear {
            startPolling()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            Task { @MainActor in
                let uploads = await BackgroundUploadService.shared.activeUploads
                let hasUploads = await BackgroundUploadService.shared.hasActiveUploads

                activeUploads = uploads
                hasActiveUploads = hasUploads

                if !hasUploads {
                    timer?.invalidate()
                    timer = nil
                }
            }
        }
    }
}

// MARK: - UploadTaskRowView

struct UploadTaskRowView: View {
    let task: BackgroundUploadService.UploadTask

    var body: some View {
        HStack {
            Image(systemName: task.isBeforePhotos ? "photo" : "photo.badge.checkmark")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(task.photos.count) \(task.isBeforePhotos ? "Before" : "After") photo\(task.photos.count == 1 ? "" : "s")")
                .font(.caption2)
                .foregroundColor(.secondary)

            Spacer()

            if let error = task.error {
                Button("Retry") {
                    Task {
                        await BackgroundUploadService.shared.retryFailedUpload(taskId: task.id)
                    }
                }
                .font(.caption2)
                .foregroundColor(.red)
            } else {
                ProgressView(value: task.progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 50)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(task.error != nil ? Color.red.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(4)
    }
}

#Preview {
    FreshWallPreview {
        BackgroundUploadIndicatorView()
    }
}

import CoreLocation
@preconcurrency import FirebaseFirestore
import Foundation

// MARK: - AddressResolutionService

/// Manages background address resolution for locations that don't have addresses yet
@MainActor
final class AddressResolutionService: @unchecked Sendable {
    private let locationCache: LocationCacheProtocol
    private let userDefaults = UserDefaults.standard
    private let pendingTasksKey = "AddressResolutionPendingTasks"
    private var isProcessingQueue = false

    init(locationCache: LocationCacheProtocol) {
        self.locationCache = locationCache

        // Process any pending tasks when service is initialized
        Task {
            await processPendingTasks()
        }
    }

    /// Queue an address resolution task for a location without an address
    func queueAddressResolution(for incidentId: String, coordinates: GeoPoint) {
        guard !coordinates.displayString.isEmpty else { return }

        Task {
            await queueTaskInternal(incidentId: incidentId, coordinates: coordinates)
        }
    }

    /// Internal method to handle async queueing logic
    private func queueTaskInternal(incidentId: String, coordinates: GeoPoint) async {
        // Check if address is already cached
        if await locationCache.getCachedAddress(for: coordinates) != nil {
            // Address is cached, resolve immediately
            await updateIncidentAddress(incidentId: incidentId, coordinates: coordinates)
            return
        }

        // Add to persistent queue
        var pendingTasks = getPendingTasks()
        let task = AddressResolutionTask(
            incidentId: incidentId,
            coordinates: coordinates,
            createdAt: Date(),
            retryCount: 0
        )

        pendingTasks[task.id] = task
        savePendingTasks(pendingTasks)

        // Start processing if not already running
        if !isProcessingQueue {
            await processPendingTasks()
        }
    }

    /// Process all pending address resolution tasks
    func processPendingTasks() async {
        guard !isProcessingQueue else { return }

        isProcessingQueue = true
        defer { isProcessingQueue = false }

        let pendingTasks = getPendingTasks()
        guard !pendingTasks.isEmpty else { return }

        print("📍 Processing \(pendingTasks.count) pending address resolution tasks")

        var completedTasks: Set<String> = []
        var failedTasks: [String: AddressResolutionTask] = [:]

        // Process tasks in batches to avoid overwhelming the geocoding service
        let taskArray = Array(pendingTasks.values).sorted { $0.createdAt < $1.createdAt }

        for task in taskArray {
            do {
                // Try to resolve address
                let coordinate = LocationService.coordinate(from: task.coordinates)
                let address = try await ModernLocationManager.reverseGeocode(coordinate: coordinate)

                // Cache the result
                await locationCache.cacheAddress(address, for: task.coordinates)

                // Update the incident
                await updateIncidentAddress(incidentId: task.incidentId, coordinates: task.coordinates)

                completedTasks.insert(task.id)
                print("✅ Resolved address for incident \(task.incidentId): \(address)")

                // Add small delay to avoid rate limiting
                try await Task.sleep(for: .milliseconds(200))

            } catch {
                print("❌ Failed to resolve address for incident \(task.incidentId): \(error)")

                // Handle retry logic
                var retryTask = task
                retryTask.retryCount += 1
                retryTask.lastAttempt = Date()

                if retryTask.retryCount < 3, !retryTask.isExpired {
                    failedTasks[task.id] = retryTask
                } else {
                    print("🚫 Giving up on address resolution for incident \(task.incidentId) after \(retryTask.retryCount) attempts")
                    completedTasks.insert(task.id)
                }
            }
        }

        // Update pending tasks - remove completed, keep failed for retry
        var updatedTasks = pendingTasks
        for taskId in completedTasks {
            updatedTasks.removeValue(forKey: taskId)
        }
        for (taskId, task) in failedTasks {
            updatedTasks[taskId] = task
        }

        savePendingTasks(updatedTasks)

        if !updatedTasks.isEmpty {
            print("📋 \(updatedTasks.count) address resolution tasks remaining")
        }
    }

    /// Update an incident's address in Firestore
    private func updateIncidentAddress(incidentId: String, coordinates: GeoPoint) async {
        guard let cachedAddress = await locationCache.getCachedAddress(for: coordinates) else {
            return
        }

        do {
            // Update the incident document with the resolved address
            let db = Firestore.firestore()

            // You'll need to adapt this to your actual Firestore structure
            // This assumes incidents are stored at /teams/{teamId}/incidents/{incidentId}
            // You may need to get the teamId from your auth service

            // For now, we'll just update the cache and let the real-time listeners handle it
            // In a full implementation, you'd update the Firestore document here

            print("📝 Would update incident \(incidentId) with address: \(cachedAddress)")

        } catch {
            print("❌ Failed to update incident \(incidentId) with address: \(error)")
        }
    }

    /// Get pending tasks from UserDefaults
    private func getPendingTasks() -> [String: AddressResolutionTask] {
        guard let data = userDefaults.data(forKey: pendingTasksKey),
              let tasks = try? JSONDecoder().decode([String: AddressResolutionTask].self, from: data) else {
            return [:]
        }

        // Filter out expired tasks (older than 7 days)
        return tasks.filter { !$0.value.isExpired }
    }

    /// Save pending tasks to UserDefaults
    private func savePendingTasks(_ tasks: [String: AddressResolutionTask]) {
        do {
            let data = try JSONEncoder().encode(tasks)
            userDefaults.set(data, forKey: pendingTasksKey)
        } catch {
            print("❌ Failed to save pending address resolution tasks: \(error)")
        }
    }

    /// Clear all pending tasks (for debugging)
    func clearPendingTasks() {
        userDefaults.removeObject(forKey: pendingTasksKey)
    }

    /// Get count of pending tasks
    var pendingTaskCount: Int {
        getPendingTasks().count
    }
}

// MARK: - AddressResolutionTask

struct AddressResolutionTask: Codable, Sendable {
    let incidentId: String
    let coordinates: GeoPoint
    let createdAt: Date
    var retryCount: Int
    var lastAttempt: Date?

    var id: String {
        "\(incidentId)_\(coordinates.latitude)_\(coordinates.longitude)"
    }

    var isExpired: Bool {
        Date().timeIntervalSince(createdAt) > 7 * 24 * 60 * 60 // 7 days
    }
}

import SwiftUI

// MARK: - TaskOnce

/// A view modifier that runs an async task only once on first appear
/// Similar to `.task` but only executes once per view lifecycle
struct TaskOnce: ViewModifier {
    @State private var hasRun = false
    @State private var task: Task<Void, Never>?
    let priority: TaskPriority
    let action: () async -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasRun else { return }

                hasRun = true

                task = Task(priority: priority) {
                    await action()
                }
            }
            .onDisappear {
                task?.cancel()
            }
    }
}

extension View {
    /// Runs an async task only once on first appear, similar to `.task` but runs only once
    /// - Parameters:
    ///   - priority: Priority of the task (default: `.userInitiated`)
    ///   - action: The async action to perform
    func taskOnce(
        priority: TaskPriority = .userInitiated,
        _ action: @escaping () async -> Void
    ) -> some View {
        modifier(TaskOnce(priority: priority, action: action))
    }
}

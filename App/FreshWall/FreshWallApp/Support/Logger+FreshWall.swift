import os

extension Logger {
    private static let subsystem = "com.freshwall.app"

    static func freshWall(category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
}

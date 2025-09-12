import Foundation

// MARK: - IncidentStatus

/// Enumeration of possible incident statuses
enum IncidentStatus: String, CaseIterable, Codable, Sendable {
    case open
    case inProgress = "in_progress"
    case completed
    case cancelled

    /// User-friendly display name for the status
    var displayName: String {
        switch self {
        case .open:
            "Open"
        case .inProgress:
            "In Progress"
        case .completed:
            "Completed"
        case .cancelled:
            "Cancelled"
        }
    }

    /// SF Symbol icon name for the status
    var iconName: String {
        switch self {
        case .open:
            "circle"
        case .inProgress:
            "clock"
        case .completed:
            "checkmark.circle.fill"
        case .cancelled:
            "xmark.circle.fill"
        }
    }

    /// Color associated with the status
    var color: String {
        switch self {
        case .open:
            "blue"
        case .inProgress:
            "orange"
        case .completed:
            "green"
        case .cancelled:
            "red"
        }
    }

    /// Whether this status represents an active incident
    var isActive: Bool {
        switch self {
        case .open, .inProgress:
            true
        case .completed, .cancelled:
            false
        }
    }
}

// MARK: - Convenience Extensions

extension IncidentStatus {
    /// Initialize from string with fallback to open
    init(stringValue: String) {
        self = IncidentStatus(rawValue: stringValue) ?? .open
    }
}

import Foundation
import UIKit

// MARK: - EditablePhoto

/// Represents a photo in an editable state - either existing (from server) or newly picked (not yet uploaded)
enum EditablePhoto: Identifiable {
    case existing(IncidentPhoto)
    case picked(PickedPhoto)

    var id: String {
        switch self {
        case let .existing(photo):
            photo.id
        case let .picked(photo):
            photo.id
        }
    }

    /// Returns the UIImage for display
    var image: UIImage? {
        switch self {
        case .existing:
            nil // Existing photos are loaded from URL
        case let .picked(photo):
            photo.image
        }
    }

    /// Returns the URL for existing photos
    var url: String? {
        switch self {
        case let .existing(photo):
            photo.url
        case .picked:
            nil
        }
    }

    /// Returns the thumbnail URL for existing photos
    var thumbnailUrl: String? {
        switch self {
        case let .existing(photo):
            photo.thumbnailUrl ?? photo.url
        case .picked:
            nil
        }
    }
}

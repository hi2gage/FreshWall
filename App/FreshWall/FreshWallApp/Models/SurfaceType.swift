import Foundation

// MARK: - SurfaceType

/// Enumeration of different surface types for incident tracking
enum SurfaceType: String, CaseIterable, Codable, Sendable {
    case concrete
    case brick
    case metal
    case glass
    case wood
    case stone
    case plastic
    case painted
    case other

    /// User-friendly display name for the surface type
    var displayName: String {
        switch self {
        case .concrete:
            "Concrete"
        case .brick:
            "Brick"
        case .metal:
            "Metal"
        case .glass:
            "Glass"
        case .wood:
            "Wood"
        case .stone:
            "Stone"
        case .plastic:
            "Plastic"
        case .painted:
            "Painted Surface"
        case .other:
            "Other"
        }
    }

    /// SF Symbol icon name for the surface type
    var iconName: String {
        switch self {
        case .concrete:
            "building.2"
        case .brick:
            "square.stack.3d.up"
        case .metal:
            "wrench.and.screwdriver"
        case .glass:
            "sparkles"
        case .wood:
            "tree"
        case .stone:
            "mountain.2"
        case .plastic:
            "cube"
        case .painted:
            "paintbrush"
        case .other:
            "questionmark.square"
        }
    }
}

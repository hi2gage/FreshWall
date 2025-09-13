import Foundation

// MARK: - IncidentNotes

/// Enhanced notes system for incidents with structured stages
struct IncidentNotes: Codable, Sendable, Hashable {
    /// Notes taken before work begins (initial assessment)
    var beforeWork: String?
    /// Notes taken during work progress
    var duringWork: String?
    /// Notes taken upon completion
    var completion: String?
    /// General notes (for backward compatibility and misc notes)
    var general: String?

    /// Initializer with all note types
    init(
        beforeWork: String? = nil,
        duringWork: String? = nil,
        completion: String? = nil,
        general: String? = nil
    ) {
        self.beforeWork = beforeWork
        self.duringWork = duringWork
        self.completion = completion
        self.general = general
    }

    /// Creates notes from legacy description field
    init(legacyDescription: String?) {
        self.general = legacyDescription
        self.beforeWork = nil
        self.duringWork = nil
        self.completion = nil
    }

    /// Combines all notes into a single string for display
    var combinedNotes: String {
        var components: [String] = []

        if let beforeWork = beforeWork?.trimmingCharacters(in: .whitespacesAndNewlines), !beforeWork.isEmpty {
            components.append("**Before Work:**\n\(beforeWork)")
        }

        if let duringWork = duringWork?.trimmingCharacters(in: .whitespacesAndNewlines), !duringWork.isEmpty {
            components.append("**During Work:**\n\(duringWork)")
        }

        if let completion = completion?.trimmingCharacters(in: .whitespacesAndNewlines), !completion.isEmpty {
            components.append("**Completion:**\n\(completion)")
        }

        if let general = general?.trimmingCharacters(in: .whitespacesAndNewlines), !general.isEmpty {
            components.append("**General Notes:**\n\(general)")
        }

        return components.joined(separator: "\n\n")
    }

    /// Legacy description for backward compatibility
    var legacyDescription: String {
        // For backward compatibility, prioritize general notes, then combine all
        if let general = general?.trimmingCharacters(in: .whitespacesAndNewlines), !general.isEmpty {
            return general
        }

        // If no general notes, combine all available notes
        let allNotes = [beforeWork, duringWork, completion]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return allNotes.joined(separator: " | ")
    }

    /// Returns the most relevant note for summary display
    var summaryNote: String? {
        // Priority: completion -> before -> during -> general
        if let completion = completion?.trimmingCharacters(in: .whitespacesAndNewlines), !completion.isEmpty {
            return completion
        }

        if let beforeWork = beforeWork?.trimmingCharacters(in: .whitespacesAndNewlines), !beforeWork.isEmpty {
            return beforeWork
        }

        if let duringWork = duringWork?.trimmingCharacters(in: .whitespacesAndNewlines), !duringWork.isEmpty {
            return duringWork
        }

        if let general = general?.trimmingCharacters(in: .whitespacesAndNewlines), !general.isEmpty {
            return general
        }

        return nil
    }

    /// Whether any notes have been entered
    var hasAnyNotes: Bool {
        [beforeWork, duringWork, completion, general]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .contains { !$0.isEmpty }
    }

    /// Number of note sections that have content
    var filledSectionsCount: Int {
        [beforeWork, duringWork, completion, general]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .count(where: { !$0.isEmpty })
    }
}

// MARK: - Firestore Support

extension IncidentNotes {
    /// Dictionary representation for use with Firestore update operations.
    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]

        if let beforeWork { dict["beforeWork"] = beforeWork }
        if let duringWork { dict["duringWork"] = duringWork }
        if let completion { dict["completion"] = completion }
        if let general { dict["general"] = general }

        return dict
    }
}

// MARK: IncidentNotes.Stage

extension IncidentNotes {
    enum Stage: String, CaseIterable {
        case beforeWork = "before_work"
        case duringWork = "during_work"
        case completion
        case general

        var displayName: String {
            switch self {
            case .beforeWork:
                "Before Work"
            case .duringWork:
                "During Work"
            case .completion:
                "Completion"
            case .general:
                "General Notes"
            }
        }

        var placeholder: String {
            switch self {
            case .beforeWork:
                "Initial assessment, surface condition, tools needed..."
            case .duringWork:
                "Progress updates, challenges encountered..."
            case .completion:
                "Work completed, final condition, recommendations..."
            case .general:
                "Additional notes or observations..."
            }
        }

        var iconName: String {
            switch self {
            case .beforeWork:
                "eye.fill"
            case .duringWork:
                "hammer.fill"
            case .completion:
                "checkmark.circle.fill"
            case .general:
                "note.text"
            }
        }
    }
}

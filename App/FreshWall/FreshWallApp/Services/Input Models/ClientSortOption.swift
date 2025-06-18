//
//  ClientSortOption.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/28/25.
//

enum ClientSortOption: CaseIterable, Hashable, Sendable {
    case nameAscending
    case nameDescending
    case lastIncidentAscending
    case lastIncidentDescending
    case createdAtAscending
    case createdAtDescending

    var field: String {
        switch self {
        case .nameAscending, .nameDescending:
            "name"
        case .lastIncidentAscending, .lastIncidentDescending:
            "lastIncidentAt"
        case .createdAtAscending, .createdAtDescending:
            "createdAt"
        }
    }

    var isDescending: Bool {
        switch self {
        case .nameAscending:
            false
        case .nameDescending:
            true
        case .lastIncidentAscending:
            false
        case .lastIncidentDescending:
            true
        case .createdAtAscending:
            false
        case .createdAtDescending:
            true
        }
    }

    /// User facing label for displaying the sort choice.
    var title: String {
        switch self {
        case .nameAscending, .nameDescending:
            "Name"
        case .lastIncidentAscending, .lastIncidentDescending:
            "Last Incident"
        case .createdAtAscending, .createdAtDescending:
            "Created"
        }
    }

    /// SF Symbol name indicating the sort direction.
    var symbolName: String {
        switch self {
        case .nameAscending, .lastIncidentAscending, .createdAtAscending:
            "arrow.up"
        case .nameDescending, .lastIncidentDescending, .createdAtDescending:
            "arrow.down"
        }
    }
}

//
//  ClientSortOption.swift
//  FreshWall
//
//  Created by Gage Halverson on 5/28/25.
//

enum ClientSortOption {
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
}

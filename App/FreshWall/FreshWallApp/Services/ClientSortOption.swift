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
            return "name"
        case .lastIncidentAscending, .lastIncidentDescending:
            return "lastIncidentAt"
        case .createdAtAscending, .createdAtDescending:
            return "createdAt"
        }
    }

    var isDescending: Bool {
        switch self {
        case .nameAscending:
            return false
        case .nameDescending:
            return true
        case .lastIncidentAscending:
            return false
        case .lastIncidentDescending:
            return true
        case .createdAtAscending:
            return false
        case .createdAtDescending:
            return true
        }
    }
}

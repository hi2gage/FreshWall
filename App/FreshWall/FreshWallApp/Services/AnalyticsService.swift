import FirebaseAnalytics
import Foundation
import os

// MARK: - AuthMethod

enum AuthMethod: String {
    case email
    case google
}

// MARK: - PhotoSource

enum PhotoSource: String {
    case camera
    case gallery
}

// MARK: - ReportFormat

enum ReportFormat: String {
    case pdf
    case csv
}

// MARK: - AnalyticEvent

enum AnalyticEvent: CustomStringConvertible {
    // Incidents
    case incidentCreated(hasClient: Bool, hasPhotos: Bool, photoCount: Int, hasLocation: Bool, billingMethod: String?)
    case incidentViewed
    case incidentEdited
    case incidentDeleted
    case incidentStatusChanged(newStatus: String)

    // Clients
    case clientCreated(hasBillingDefaults: Bool)
    case clientViewed
    case clientEdited
    case clientDeleted

    // Photos
    case photosCaptured(count: Int, source: PhotoSource)

    // Reports
    case reportGenerated(incidentCount: Int, format: ReportFormat)

    // Auth
    case login(method: AuthMethod)
    case signUp(method: AuthMethod)
    case logout

    // Team
    case teamJoined
    case teamCreated

    var name: String {
        switch self {
        case .incidentCreated: "incident_created"
        case .incidentViewed: "incident_viewed"
        case .incidentEdited: "incident_edited"
        case .incidentDeleted: "incident_deleted"
        case .incidentStatusChanged: "incident_status_changed"
        case .clientCreated: "client_created"
        case .clientViewed: "client_viewed"
        case .clientEdited: "client_edited"
        case .clientDeleted: "client_deleted"
        case .photosCaptured: "photos_captured"
        case .reportGenerated: "report_generated"
        case .login: AnalyticsEventLogin
        case .signUp: AnalyticsEventSignUp
        case .logout: "logout"
        case .teamJoined: "team_joined"
        case .teamCreated: "team_created"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case let .incidentCreated(hasClient, hasPhotos, photoCount, hasLocation, billingMethod):
            [
                "has_client": hasClient,
                "has_photos": hasPhotos,
                "photo_count": photoCount,
                "has_location": hasLocation,
                "billing_method": billingMethod ?? "none",
            ]
        case .incidentViewed, .incidentEdited, .incidentDeleted:
            nil
        case let .incidentStatusChanged(newStatus):
            ["new_status": newStatus]
        case let .clientCreated(hasBillingDefaults):
            ["has_billing_defaults": hasBillingDefaults]
        case .clientViewed, .clientEdited, .clientDeleted:
            nil
        case let .photosCaptured(count, source):
            ["count": count, "source": source.rawValue]
        case let .reportGenerated(incidentCount, format):
            ["incident_count": incidentCount, "format": format.rawValue]
        case let .login(method):
            [AnalyticsParameterMethod: method.rawValue]
        case let .signUp(method):
            [AnalyticsParameterMethod: method.rawValue]
        case .logout, .teamJoined, .teamCreated:
            nil
        }
    }

    var description: String {
        if let parameters {
            let paramString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            return "\(name) [\(paramString)]"
        }
        return name
    }
}

// MARK: - FWAnalytics

enum FWAnalytics {
    private static let logger = Logger.freshWall(category: "Analytics")

    static func log(_ event: AnalyticEvent) {
        logger.info("📊 \(event)")
        Analytics.logEvent(event.name, parameters: event.parameters)
    }

    static func setUserRole(_ role: String) {
        logger.info("📊 setUserRole: \(role)")
        Analytics.setUserProperty(role, forName: "user_role")
    }

    static func setTeamId(_ teamId: String) {
        logger.info("📊 setTeamId: \(teamId)")
        Analytics.setUserProperty(teamId, forName: "team_id")
    }
}

import Foundation

public enum NetworkError: LocalizedError {
    case notAuthenticated
    case invalidTeamContext
    case permissionDenied
    case documentNotFound
    case networkFailure(Error)
    case decodingError(Error)
    case invalidData
    case serverError(String)
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            "You must be logged in to perform this action"
        case .invalidTeamContext:
            "Invalid team context"
        case .permissionDenied:
            "You don't have permission to perform this action"
        case .documentNotFound:
            "The requested item was not found"
        case let .networkFailure(error):
            "Network error: \(error.localizedDescription)"
        case .decodingError:
            "Failed to process server response"
        case .invalidData:
            "Invalid data received from server"
        case let .serverError(message):
            "Server error: \(message)"
        case let .unknown(error):
            "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

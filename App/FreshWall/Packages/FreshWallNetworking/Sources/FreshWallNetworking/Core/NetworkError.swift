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
            return "You must be logged in to perform this action"
        case .invalidTeamContext:
            return "Invalid team context"
        case .permissionDenied:
            return "You don't have permission to perform this action"
        case .documentNotFound:
            return "The requested item was not found"
        case let .networkFailure(error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError:
            return "Failed to process server response"
        case .invalidData:
            return "Invalid data received from server"
        case let .serverError(message):
            return "Server error: \(message)"
        case let .unknown(error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

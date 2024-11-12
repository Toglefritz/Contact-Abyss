import Foundation

/// Defines errors that can occur during communication.
enum CommunicationError: Error, LocalizedError {
    /// Indicates that the iOS app is not reachable.
    case notReachable
    
    /// Indicates that the response from the iOS app was invalid.
    case invalidResponse
    
    /// Provides a localized description for the error.
    var errorDescription: String? {
        switch self {
        case .notReachable:
            return "iOS app is not reachable."
        case .invalidResponse:
            return "Received an invalid response."
        }
    }
}

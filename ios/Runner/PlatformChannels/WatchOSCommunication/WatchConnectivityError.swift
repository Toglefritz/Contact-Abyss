/// Enum representing errors that can occur during Watch Connectivity operations.
enum WatchConnectivityError: Error {
    case watchNotReachable
    case messageSendingFailed(String)
    case unknownError
}

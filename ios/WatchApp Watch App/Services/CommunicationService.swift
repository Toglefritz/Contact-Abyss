import WatchConnectivity
import Combine

// MARK: - Core Communication Service

/// The `CommunicationService` class is responsible for managing communication between the WatchOS app and the iOS app.
///
/// This class provides the fundamental, reusable functionality for managing Watch Connectivity (`WCSession`). It handles
/// session initialization, message sending with retry logic, and WCSession delegation. The methods here are designed
/// to be generic and applicable to any WatchOS/iOS companion app setup, making it a reusable and extendable communication
/// service. Any app-specific functionality is built on top of this core class, usually in an extension or subclass.
class CommunicationService: NSObject, WCSessionDelegate {
    /// The singleton instance of `CommunicationService`, ensuring a single communication manager throughout the app.
    ///
    /// The singleton pattern is used to make sure that there is only one communication point, preventing multiple
    /// WCSession delegates and ensuring consistent state management for the session.
    static let shared = CommunicationService()
    
    // MARK: - WCSession
    
    /// The `WCSession` default instance for Watch Connectivity communication.
    ///
    /// This is the default instance of `WCSession` that handles all communication between the WatchOS and iOS apps.
    /// The session must be activated, and the current instance set as its delegate for proper communication.
    private let session: WCSession = .default
    
    // MARK: - Publishers
    
    /// Publisher for notifying subscribers about reachability changes.
    ///
    /// This publisher broadcasts updates about the reachability state of the iOS app. It is used by other parts of the
    /// app to react accordingly when the communication availability changes, such as updating UI or changing the flow
    /// based on whether the companion iOS app can be reached.
    let reachabilityPublisher = PassthroughSubject<Bool, Never>()
    
    /// Publishes all received messages.
    ///
    /// This publisher is a `PassthroughSubject` that emits every message received from the iOS app. This allows
    /// subscribers (like AppSpecificCommunicationManager) to react to incoming messages.
    let receivedMessagePublisher = PassthroughSubject<[String: Any], Never>()
    
    // MARK: - Initializer
    
    /// Private initializer to enforce the singleton pattern.
    ///
    /// The initializer is marked private to prevent external instantiation of this class. It checks if `WCSession` is
    /// supported on the current device, assigns this class as the session delegate, and activates the session to start
    /// the communication process.
    private override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - Generic Methods
    
    /// Sends a message to the iOS app with a retry mechanism.
    ///
    /// This method is used to send data to the iOS app reliably. If the first attempt to send the message fails,
    /// it will retry up to the specified number of retries (`maxRetries`) with a delay (`retryDelay`) between attempts.
    /// This helps mitigate temporary connectivity issues.
    ///
    /// - Parameters:
    ///   - message: A dictionary containing the data to send.
    ///   - maxRetries: The maximum number of retry attempts. Defaults to 3.
    ///   - retryDelay: The delay between retry attempts in seconds. Defaults to 1.0 seconds.
    ///   - completion: A closure to handle the result, containing either the response from the iOS app or an error.
    func sendMessage(_ message: [String: Any],
                     maxRetries: Int = 3,
                     retryDelay: TimeInterval = 1.0,
                     completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Start the send attempt with the maximum number of retries.
        attemptSend(message, retriesRemaining: maxRetries, delay: retryDelay, completion: completion)
    }
    
    // MARK: - Private Helper Methods
    
    /// Attempts to send a message to the iOS app, retrying upon failure.
    ///
    /// This method handles the logic for retrying a message send if the initial attempt fails. It checks whether the
    /// iOS app is reachable and, if not, schedules retries with a specified delay. This is useful in cases where
    /// connectivity between the WatchOS and iOS apps is temporarily disrupted, such as when the app is just launched.
    ///
    /// - Parameters:
    ///   - message: The message dictionary to send.
    ///   - retriesRemaining: The number of remaining retry attempts.
    ///   - delay: The delay before the next retry attempt.
    ///   - completion: The completion handler to call with the result of the send operation.
    private func attemptSend(_ message: [String: Any],
                             retriesRemaining: Int,
                             delay: TimeInterval,
                             completion: @escaping (Result<[String: Any], Error>) -> Void) {
        
        // Check if the iOS app is reachable. If not, retry after the specified delay up to the maximum number of retries.
        guard session.isReachable else {
            if retriesRemaining > 0 {
                print("iOS app not reachable. Retrying in \(delay) seconds. Attempts left: \(retriesRemaining)")
                // Schedule the next retry attempt after the specified delay.
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    self?.attemptSend(message, retriesRemaining: retriesRemaining - 1, delay: delay, completion: completion)
                }
            } else {
                // All retry attempts exhausted. Return failure.
                print("iOS app not reachable. No more retry attempts.")
                completion(.failure(CommunicationError.notReachable))
            }
            return
        }
        
        // Attempt to send the message. This method too will retry on failure if needed.
        session.sendMessage(message, replyHandler: { response in
            // Check if the first key is "error"
            if let firstKey = response.keys.first, firstKey == "error" {
                print("Error received from Dart/Flutter side: \(response[firstKey] ?? "Unknown error")")
                let error = NSError(domain: "CommunicationService", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: response[firstKey] ?? "An unknown error occurred."
                ])
                completion(.failure(error))
            } else {
                completion(.success(response))
            }
        }, errorHandler: { error in
            if retriesRemaining > 0 {
                print("Failed to send message: \(error.localizedDescription). Retrying in \(delay) seconds. Attempts left: \(retriesRemaining)")
                // Schedule the next retry attempt after the specified delay.
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    self?.attemptSend(message, retriesRemaining: retriesRemaining - 1, delay: delay, completion: completion)
                }
            } else {
                // All retry attempts exhausted. Return failure.
                print("Failed to send message: \(error.localizedDescription). No more retry attempts.")
                completion(.failure(error))
            }
        })
    }
    
    // MARK: - WCSessionDelegate Methods
    
    /// Handles the completion of `WCSession` activation.
    ///
    /// This delegate method is called when the session activation process is complete, indicating whether the activation
    /// was successful or if an error occurred. The activation process is crucial for enabling communication between
    /// the WatchOS and iOS apps.
    ///
    /// - Parameters:
    ///   - session: The `WCSession` instance.
    ///   - activationState: The state of the session after activation.
    ///   - error: An optional error if activation failed.
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        }
    }
    
    /// Handles changes in the reachability of the iOS app.
    ///
    /// This method is called whenever the reachability status of the paired iOS app changes. It updates the
    /// `reachabilityPublisher` to notify any subscribers about the current state. This is helpful for reacting to
    /// connectivity changes and adjusting app behavior accordingly.
    ///
    /// - Parameter session: The `WCSession` instance whose reachability changed.
    func sessionReachabilityDidChange(_ session: WCSession) {
        reachabilityPublisher.send(session.isReachable)
    }
}

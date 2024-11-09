import WatchConnectivity
import Combine

/// The `CommunicationService` class manages the communication between the WatchOS app and the iOS app
/// using the `WCSession` framework. It provides methods to send messages, handle replies, and process
/// data received from the iOS app.
///
/// ## Features
/// - Acts as a singleton for centralized communication management.
/// - Provides methods for sending actions like starting a new game or making a choice.
/// - Publishes updates to `ViewModel`s using Combine's `Publisher` for game state updates and errors.
/// - Implements `WCSessionDelegate` to handle incoming messages and session state changes.
class CommunicationService: NSObject, WCSessionDelegate {
    /// The singleton instance of `CommunicationService`, ensuring a single communication manager throughout the app.
    static let shared = CommunicationService()
    
    // MARK: - WCSession
    
    /// The `WCSession` default instance for Watch Connectivity communication.
    private let session: WCSession = .default
    
    // MARK: - Publishers
    
    /// Publisher for notifying `ViewModel`s about the current game node.
    let gameNodePublisher = PassthroughSubject<GameNode?, Never>()
    
    /// Publisher for notifying `ViewModel`s when there is no active game.
    let noActiveGamePublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Initializer
    
    /// Private initializer to enforce the singleton pattern.
    ///
    /// - Checks if `WCSession` is supported, sets this class as its delegate, and activates the session.
    private override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    // MARK: - Public Methods
    
    /// Sends a message to the iOS app with a retry mechanism.
    ///
    /// - Parameters:
    ///   - message: A dictionary containing the data to send.
    ///   - maxRetries: The maximum number of retry attempts. Defaults to 3.
    ///   - retryDelay: The delay between retry attempts in seconds. Defaults to 1.0 seconds.
    ///   - completion: A closure to handle the result, containing either the response or an error.
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
    /// - Parameters:
    ///   - message: The message dictionary to send.
    ///   - retriesRemaining: The number of remaining retry attempts.
    ///   - delay: The delay before the next retry attempt.
    ///   - completion: The completion handler to call with the result.
    private func attemptSend(_ message: [String: Any],
                             retriesRemaining: Int,
                             delay: TimeInterval,
                             completion: @escaping (Result<[String: Any], Error>) -> Void) {
        
        // Check if the iOS app is reachable.
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
        
        // Attempt to send the message.
        session.sendMessage(message, replyHandler: { response in
            // Message sent successfully. Return the response.
            print("Message sent successfully: \(response)")
            completion(.success(response))
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
    
    /// Requests the current game node from the iOS app.
    ///
    /// - Parameter completion: A closure that receives either the `GameNode` or an error.
    func requestCurrentGameNode(completion: @escaping (Result<GameNode?, Error>) -> Void) {
        sendMessage(["action": "requestCurrentGameNode"]) { result in
            switch result {
            case .success(let response):
                if let responseDict = response["gameNode"] as? [String: Any],
                   let gameNode = GameNode(json: responseDict) {
                    completion(.success(gameNode))
                } else {
                    completion(.success(nil)) // No active game
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Starts a new game by communicating with the iOS app.
    ///
    /// - Parameter completion: A closure that receives the new `GameNode` or an error.
    func startNewGame(completion: @escaping (Result<GameNode?, Error>) -> Void) {
        sendMessage(["action": "startNewGame"]) { result in
            switch result {
            case .success(let response):
                if let responseDict = response["gameNode"] as? [String: Any],
                   let gameNode = GameNode(json: responseDict) {
                    completion(.success(gameNode))
                } else {
                    completion(.failure(CommunicationError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Sends the user's choice to the iOS app and requests the next game node.
    ///
    /// - Parameters:
    ///   - choice: The user's choice represented as a `Choice` object.
    ///   - completion: A closure that receives the next `GameNode` or an error.
    func makeChoice(_ choice: Choice, completion: @escaping (Result<GameNode?, Error>) -> Void) {
        let message: [String: Any] = ["action": "makeChoice", "choice": choice.toJson()]
        sendMessage(message) { result in
            switch result {
            case .success(let response):
                if let responseDict = response["gameNode"] as? [String: Any],
                   let gameNode = GameNode(json: responseDict) {
                    completion(.success(gameNode))
                } else {
                    completion(.failure(CommunicationError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - WCSessionDelegate Methods
    
    /// Handles messages received from the iOS app.
    ///
    /// - Parameters:
    ///   - session: The `WCSession` instance managing the communication.
    ///   - message: A dictionary containing the data sent by the iOS app.
    ///   - replyHandler: A closure to send a reply back to the iOS app.
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        if let action = message["action"] as? String {
            switch action {
            case "gameNodeUpdate":
                if let gameNodeDict = message["gameNode"] as? [String: Any],
                   let gameNode = GameNode(json: gameNodeDict) {
                    gameNodePublisher.send(gameNode)
                }
            case "noActiveGame":
                noActiveGamePublisher.send()
            default:
                break
            }
        }
        replyHandler(["status": "received"])
    }
    
    /// Handles the completion of WCSession activation.
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
    
    // MARK: - Error Definitions
    
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
}

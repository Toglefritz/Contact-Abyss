// MARK: - Application-Specific Communication Extension

/// Extension of `CommunicationService` that provides methods and functionality specific to the current application.
///
/// The `CommunicationService` core class is designed to handle generic WatchOS to iOS communication, implementing
/// fundamental methods that can be used in any WatchOS app paired with an iOS companion app. These include session
/// management, general-purpose message sending with retry mechanisms, and maintaining the communication infrastructure.
///
/// This extension, `CommunicationService` extension, builds upon that core infrastructure to provide application-specific
/// features. It defines functions that are specific to the logic of the current app, like requesting game state or
/// sending user choices. These functions utilize the generic methods provided by `CommunicationService` but add higher-level
/// business logic required for the app's unique requirements.
extension CommunicationService {
    
    /// Requests the current game node from the iOS app.
    ///
    /// This method sends a message to the iOS app to request information about the current game node.
    /// If a game is ongoing, it receives the `gameNode` details. If there is no active game, it returns nil.
    /// - Parameter completion: A closure called with the result of the request, containing either a `GameNode` object
    ///   or an error if the request failed.
    func requestCurrentGameNode(completion: @escaping (Result<GameNode?, Error>) -> Void) {
        let message = ["action": "requestCurrentGameNode"]
        sendMessage(message) { result in
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
    /// This method sends a message to the iOS app to initiate a new game session. The iOS app is expected to
    /// return information about the new `gameNode` created. If the operation is successful, the game node is returned.
    /// - Parameter completion: A closure called with the result of the request, containing either a `GameNode` object
    ///   or an error if the operation failed.
    func startNewGame(completion: @escaping (Result<GameNode?, Error>) -> Void) {
        let message = ["action": "startNewGame"]
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

    /// Sends the user's choice to the iOS app and requests the next game node.
    ///
    /// This method allows the user to make a choice in the current game. It sends the selected choice to the iOS app
    /// and expects a new game node in response, representing the outcome of the choice made.
    /// - Parameters:
    ///   - choice: A `Choice` object representing the user's decision.
    ///   - completion: A closure called with the result of the request, containing either a `GameNode` object representing
    ///     the next stage of the game or an error if the operation failed.
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
    
    // MARK: - Handling Received Messages (App Specific)
    
    /// Handles incoming messages from the iOS app that are specific to the application.
    ///
    /// This method processes messages that are received from the iOS app and takes appropriate actions based on
    /// the message's contents. These actions include updating the game state or notifying subscribers of the current
    /// state of the game.
    /// - Parameter message: A dictionary representing the received message.
    func handleAppSpecificMessages(message: [String: Any]) {
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
    }
    
    // MARK: - WCSessionDelegate Methods Override
    
    /// Handles messages received from the iOS app via the `WCSession` delegate.
    ///
    /// This delegate method is called whenever a message is received from the paired iOS app. It processes the message
    /// by calling `handleAppSpecificMessages` and sends an acknowledgment reply to the sender.
    /// - Parameters:
    ///   - session: The `WCSession` instance that received the message.
    ///   - message: A dictionary representing the received message.
    ///   - replyHandler: A closure used to send a response back to the sender.
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        handleAppSpecificMessages(message: message)
        replyHandler(["status": "received"])
    }
}

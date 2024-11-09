import WatchConnectivity
import Combine

class CommunicationService: NSObject, WCSessionDelegate {
    // Singleton instance
    static let shared = CommunicationService()

    // WCSession default instance
    private let session: WCSession = .default

    // Publishers to notify ViewModels about received data
    let gameNodePublisher = PassthroughSubject<GameNode?, Never>()
    let noActiveGamePublisher = PassthroughSubject<Void, Never>()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - Public Methods

    /// Sends a message to the iOS app and handles the reply.
    ///
    /// - Parameters:
    ///   - message: A dictionary containing the data to send.
    ///   - completion: A closure to handle the result.
    func sendMessage(_ message: [String: Any], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard session.isReachable else {
            completion(.failure(CommunicationError.notReachable))
            return
        }

        session.sendMessage(message, replyHandler: { response in
            completion(.success(response))
        }, errorHandler: { error in
            completion(.failure(error))
        })
    }

    /// Requests the current game node from the iOS app.
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

    // Handle WCSession activation and errors
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Error Definitions

    enum CommunicationError: Error, LocalizedError {
        case notReachable
        case invalidResponse

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

import Foundation
import Combine

/// AppSpecificCommunicationManager handles application-specific communication tasks,
/// leveraging the generic CommunicationService for underlying message exchange.
///
/// The `CommunicationService` core class is designed to handle generic WatchOS to iOS communication, implementing
/// fundamental methods that can be used in any WatchOS app paired with an iOS companion app. These include session
/// management, general-purpose message sending with retry mechanisms, and maintaining the communication infrastructure.
///
/// This extension, `CommunicationService` extension, builds upon that core infrastructure to provide application-specific
/// features. It defines functions that are specific to the logic of the current app, like requesting game state or
/// sending user choices. These functions utilize the generic methods provided by `CommunicationService` but add higher-level
/// business logic required for the app's unique requirements.
class AppSpecificCommunicationManager {
    
    // MARK: - Singleton Instance
    static let shared = AppSpecificCommunicationManager()
    
    // MARK: - Publishers
    
    /// Publishes updates to the current game node.
    let gameNodePublisher = PassthroughSubject<GameNode, Never>()
    
    /// Publishes events indicating that there is no active game.
    let noActiveGamePublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - Dependencies
    
    private let communicationService: CommunicationService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(communicationService: CommunicationService = .shared) {
        self.communicationService = communicationService
        setupBindings()
    }
    
    // MARK: - Setup
    
    /// Sets up bindings to handle incoming messages from CommunicationService.
    private func setupBindings() {
        communicationService.receivedMessagePublisher
            .sink { [weak self] message in
                self?.handleAppSpecificMessages(message: message)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Message Handling
    
    /// Handles incoming messages specific to the application.
    /// - Parameter message: The received message dictionary.
    private func handleAppSpecificMessages(message: [String: Any]) {
        guard let action = message["action"] as? String else { return }
        
        switch action {
        case "gameNodeUpdate":
            if let gameNodeDict = message["gameNode"] as? [String: Any],
               let gameNode = GameNode(json: gameNodeDict) {
                gameNodePublisher.send(gameNode)
            }
        case "noActiveGame":
            noActiveGamePublisher.send(())
        default:
            break
        }
    }
    
    // MARK: - Application-Specific Methods
    
    /// Requests the current game node from the iOS app.
    /// - Parameter completion: A closure called with the result of the request.
    func requestCurrentGameNode(completion: @escaping (Result<GameNode?, Error>) -> Void) {
        let message = ["action": "requestCurrentGameNode"]
        communicationService.sendMessage(message) { result in
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
    /// - Parameter completion: A closure called with the result of the request.
    func startNewGame(completion: @escaping (Result<GameNode?, Error>) -> Void) {
        let message = ["action": "startNewGame"]
        communicationService.sendMessage(message) { result in
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
    /// - Parameters:
    ///   - choice: A `Choice` object representing the user's decision.
    ///   - completion: A closure called with the result of the request.
    func makeChoice(_ choice: Choice, completion: @escaping (Result<GameNode?, Error>) -> Void) {
        let message: [String: Any] = ["action": "makeChoice", "choice": choice.toJson()]
        communicationService.sendMessage(message) { result in
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
}

import Foundation
import Combine

/// The `HomeViewModel` class manages the logic for the `HomeView`, including starting a new game.
/// It interacts with the `AppSpecificCommunicationManager` to send messages to the iOS app and handles the response.
///
/// ## Features
/// - Provides a method (`startNewGame`) to initiate a new game by communicating with the iOS app.
/// - Publishes an `errorMessage` property to notify the view of errors encountered during communication.
///
/// ## Behavior
/// - When `startNewGame` is called, the view model sends a request to the iOS app via `AppSpecificCommunicationManager`.
/// - On a successful response, it posts a notification with the new game node, which other parts of the app can observe.
/// - If the operation fails, it updates the `errorMessage` property for the view to display feedback.
///
/// ## Dependencies
/// - Depends on the `AppSpecificCommunicationManager` singleton for Watch-to-iOS communication.
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// A flag to determine the next navigation destination.
    ///
    /// - `navigationDestination`: When set to a specific `AppDestination` case, it triggers navigation within the `RootView`.
    @Published var navigationDestination: AppDestination? = nil
    
    /// An optional error message, updated when a communication failure occurs.
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    /// The app-specific communication manager used to interact with the iOS app.
    private var appCommunicationManager: AppSpecificCommunicationManager
    
    /// A set of cancellable subscriptions used for Combine publishers to avoid memory leaks.
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    /// Initializes the `HomeViewModel` with an optional `AppSpecificCommunicationManager` dependency.
    ///
    /// - Parameter appCommunicationManager: The communication manager instance. Defaults to the singleton instance.
    init(appCommunicationManager: AppSpecificCommunicationManager = AppSpecificCommunicationManager.shared) {
        self.appCommunicationManager = appCommunicationManager
        setupIncomingMessageListener()
    }
    
    // MARK: - Methods
    
    /// Sets up a listener for incoming messages from the Flutter app.
    ///
    /// This method subscribes to the `receivedMessagePublisher` of the `CommunicationService`.
    /// When a message containing a `GameNode` is received, it updates the `navigationDestination`
    /// to trigger navigation to the `GameView`.
    ///
    /// This listener is used if a new game is started from the Flutter app. When this happens the Flutter app will
    /// send a `GameNode` instance to the WatchOS app.
    private func setupIncomingMessageListener() {
        CommunicationService.shared.receivedMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                // Debug: Print the received message
                print("HomeViewModel received message: \(message)")
                
                // Check if the message contains a GameNode
                if let gameNodeDict = message["gameNode"] as? [String: Any],
                   let gameNode = GameNode(json: gameNodeDict) {
                    print("Received GameNode from Flutter app: \(gameNode.id)")
                    self?.navigationDestination = .game(gameNode)
                }
                // Handle other message types if necessary
            }
            .store(in: &cancellables)
    }
    
    /// Sends a request to the iOS app to start a new game.
    ///
    /// - On success:
    ///   - Posts a notification with the new game node, enabling navigation to the game node view.
    /// - On failure:
    ///   - Updates the `errorMessage` property with the error description.
    func startNewGame() {
        appCommunicationManager.startNewGame { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let gameNode):
                    if let node = gameNode {
                        // Naigate to the GameView
                        self?.navigationDestination = .game(node)
                    } else {
                        // Handle the edge case where no game node is returned.
                        self?.errorMessage = "Failed to start a new game."
                    }
                case .failure(let error):
                    // Update the error message on communication failure.
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

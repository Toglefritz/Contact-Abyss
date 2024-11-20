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
    
    /// An optional error message, updated when a communication failure occurs.
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    /// The app-specific communication manager used to interact with the iOS app.
    private var appCommunicationManager: AppSpecificCommunicationManager
    
    // MARK: - Initializer
    
    /// Initializes the `HomeViewModel` with an optional `AppSpecificCommunicationManager` dependency.
    ///
    /// - Parameter appCommunicationManager: The communication manager instance. Defaults to the singleton instance.
    init(appCommunicationManager: AppSpecificCommunicationManager = AppSpecificCommunicationManager.shared) {
        self.appCommunicationManager = appCommunicationManager
    }
    
    // MARK: - Methods
    
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
                        // Notify other parts of the app with the new game node.
                        NotificationCenter.default.post(name: .didReceiveGameNode, object: node)
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

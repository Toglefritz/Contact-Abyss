import Foundation
import Combine

/// The `GameViewModel` class manages the logic and state for the `GameView`.
/// It handles the current game node, processes the user's choices, and updates the state based on responses from the iOS app.
///
/// ## Features
/// - Maintains the current `GameNode` displayed in the `GameView`.
/// - Processes the user's selection of a choice by sending the data to the iOS app.
/// - Reactively updates the game node and displays error messages when necessary.
///
/// ## Behavior
/// - The `gameNode` property is updated with the new node received from the iOS app.
/// - If the game ends or an invalid node is received, the `errorMessage` property is updated.
///
/// ## Dependencies
/// - Depends on the `CommunicationService` singleton for Watch-to-iOS communication.
class GameViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The current game node displayed in the `GameView`.
    @Published var gameNode: GameNode

    /// An optional error message, updated when a communication failure occurs.
    @Published var errorMessage: String?

    // MARK: - Dependencies

    /// The communication service used to interact with the iOS app.
    private var communicationService: CommunicationService

    // MARK: - Initializer

    /// Initializes the `GameViewModel` with the given `GameNode` and optional `CommunicationService`.
    ///
    /// - Parameters:
    ///   - gameNode: The initial game node to display in the `GameView`.
    ///   - communicationService: The communication service instance. Defaults to the singleton instance.
    init(gameNode: GameNode, communicationService: CommunicationService = CommunicationService.shared) {
        self.gameNode = gameNode
        self.communicationService = communicationService
    }

    // MARK: - Methods

    /// Sends the selected choice to the iOS app and updates the game node based on the response.
    ///
    /// - Parameter choice: The user's selected choice.
    ///
    /// - Behavior:
    ///   - If the iOS app responds with a valid game node, updates `gameNode`.
    ///   - If the response is invalid or the game ends, updates `errorMessage`.
    func selectChoice(_ choice: Choice) {
        communicationService.makeChoice(choice) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newGameNode):
                    if let node = newGameNode {
                        // Update the current game node with the new node
                        self?.gameNode = node
                    } else {
                        // Handle end of game or invalid response
                        self?.errorMessage = "Invalid game node received."
                    }
                case .failure(let error):
                    // Update error message on communication failure
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

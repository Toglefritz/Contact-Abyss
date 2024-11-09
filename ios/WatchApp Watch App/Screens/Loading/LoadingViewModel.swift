import Foundation
import Combine

/// The `LoadingViewModel` class serves as the view model for the `LoadingView`.
/// It manages the logic for fetching the current game node and observing updates to game state.
/// This class conforms to the `ObservableObject` protocol, allowing views to reactively update
/// when its published properties change.
class LoadingViewModel: ObservableObject {
    // MARK: - Properties
    
    /// The singleton instance of the `CommunicationService`, used to interact with the iOS app.
    private let communicationService = CommunicationService.shared
    
    /// A set of cancellable subscriptions used for Combine publishers to avoid memory leaks.
    private var cancellables: Set<AnyCancellable> = []
    
    /// The current game node received from the iOS app.
    @Published var currentGameNode: GameNode?
    
    /// A Boolean indicating whether the user should start a new game.
    @Published var isNewGame: Bool = false
    
    /// An optional error message, displayed if a request fails.
    @Published var errorMessage: String?
    
    // MARK: - Methods
    
    /// Fetches the current game node from the iOS app.
    ///
    /// - Communicates with the `CommunicationService` to send a request to the iOS app.
    /// - Updates `currentGameNode` and `isNewGame` based on the response.
    func fetchCurrentGameNode() {
        communicationService.requestCurrentGameNode { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let gameNode):
                    // If a game node exists, update properties accordingly.
                    if let node = gameNode {
                        self?.currentGameNode = node
                        self?.isNewGame = false
                    } else {
                        // If no active game exists, set flags for starting a new game.
                        self?.currentGameNode = nil
                        self?.isNewGame = true
                    }
                case .failure(let error):
                    // Update `errorMessage` if the request fails.
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    /// Observes updates to the game node and active game state from the `CommunicationService`.
    ///
    /// - Subscribes to the `gameNodePublisher` and `noActiveGamePublisher` to receive updates.
    /// - Updates `currentGameNode` and `isNewGame` reactively based on the received data.
    func observeGameNodeUpdates() {
        communicationService.gameNodePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gameNode in
                // Update properties based on the received game node.
                self?.currentGameNode = gameNode
                self?.isNewGame = gameNode == nil
            }
            .store(in: &cancellables)
        
        communicationService.noActiveGamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                // Set properties for a new game when no active game notification is received.
                self?.currentGameNode = nil
                self?.isNewGame = true
            }
            .store(in: &cancellables)
    }
}

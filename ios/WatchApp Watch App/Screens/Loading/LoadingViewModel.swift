import Foundation
import Combine

/// The `LoadingViewModel` class serves as the view model for the `LoadingView`.
/// It manages the logic for fetching the current game node and observing updates to game state.
/// This class conforms to the `ObservableObject` protocol, allowing views to reactively update
/// when its published properties change.
class LoadingViewModel: ObservableObject {
    // MARK: - Properties
    
    /// The instance of the `AppSpecificCommunicationManager`, used to interact with the iOS app.
    private let appCommunicationManager: AppSpecificCommunicationManager
    
    /// A set of cancellable subscriptions used for Combine publishers to avoid memory leaks.
    private var cancellables: Set<AnyCancellable> = []
    
    /// The current game node received from the iOS app.
    @Published var currentGameNode: GameNode?
    
    /// An optional error message, displayed if a request fails.
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    
    /// Initializes the `LoadingViewModel` with an instance of `AppSpecificCommunicationManager`.
    ///
    /// - Parameter appCommunicationManager: The manager handling app-specific communication. Defaults to the shared instance.
    init(appCommunicationManager: AppSpecificCommunicationManager = .shared) {
        self.appCommunicationManager = appCommunicationManager
        setupBindings()
    }
    
    // MARK: - Setup Bindings
    
    /// Sets up Combine subscriptions to the publishers from `AppSpecificCommunicationManager`.
    private func setupBindings() {
        // Subscribe to game node updates
        appCommunicationManager.gameNodePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gameNode in
                // Update properties based on the received game node.
                self?.currentGameNode = gameNode
            }
            .store(in: &cancellables)
        
        // Subscribe to no active game events
        appCommunicationManager.noActiveGamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                // Set properties for a new game when no active game notification is received.
                self?.currentGameNode = nil
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    
    /// Fetches the current game node from the iOS app.
    ///
    /// - Communicates with the `AppSpecificCommunicationManager` to send a request to the iOS app.
    /// - Updates `currentGameNode` and `isNewGame` based on the response.
    func fetchCurrentGameNode() {
        appCommunicationManager.requestCurrentGameNode { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let gameNode):
                    // If a game node exists, update properties accordingly.
                    if let node = gameNode {
                        self?.currentGameNode = node
                    } else {
                        // If no active game exists, set flags for starting a new game.
                        self?.currentGameNode = nil
                    }
                case .failure(let error):
                    // Update `errorMessage` if the request fails.
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

import Foundation
import Combine

class GameViewModel: ObservableObject {
    @Published var gameNode: GameNode
    @Published var errorMessage: String?
    
    private var communicationService: CommunicationService
    
    init(gameNode: GameNode, communicationService: CommunicationService = CommunicationService.shared) {
        self.gameNode = gameNode
        self.communicationService = communicationService
    }
    
    func selectChoice(_ choice: Choice) {
        communicationService.makeChoice(choice) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newGameNode):
                    if let node = newGameNode {
                        self?.gameNode = node
                    } else {
                        // Handle end of game or invalid node
                        self?.errorMessage = "Invalid game node received."
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

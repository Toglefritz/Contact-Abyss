import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var errorMessage: String?
    
    private var communicationService: CommunicationService
    
    init(communicationService: CommunicationService = CommunicationService.shared) {
        self.communicationService = communicationService
    }
    
    func startNewGame() {
        communicationService.startNewGame { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let gameNode):
                    if let node = gameNode {
                        // Navigate to GameNodeView with the new node
                        NotificationCenter.default.post(name: .didReceiveGameNode, object: node)
                    } else {
                        self?.errorMessage = "Failed to start a new game."
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

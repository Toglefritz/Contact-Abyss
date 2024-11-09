import Foundation
import Combine

class LoadingViewModel: ObservableObject {
    private let communicationService = CommunicationService.shared
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var currentGameNode: GameNode?
    @Published var isNewGame: Bool = false
    @Published var errorMessage: String?
    
    func fetchCurrentGameNode() {
        communicationService.requestCurrentGameNode { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let gameNode):
                    if let node = gameNode {
                        self?.currentGameNode = node
                        self?.isNewGame = false
                    } else {
                        self?.currentGameNode = nil
                        self?.isNewGame = true
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func observeGameNodeUpdates() {
        communicationService.gameNodePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gameNode in
                self?.currentGameNode = gameNode
                self?.isNewGame = gameNode == nil
            }
            .store(in: &cancellables)
        
        communicationService.noActiveGamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.currentGameNode = nil
                self?.isNewGame = true
            }
            .store(in: &cancellables)
    }
}

import SwiftUI

/// The root view of the WatchOS app that manages and controls the overall navigation flow.
///
/// `RootView` listens to the navigation destination from both `LoadingViewModel` and `HomeViewModel`
/// to determine which view to display. It acts as the central hub for switching between different screens
/// based on the app's state, ensuring that users are directed to the appropriate interface.
///
/// This approach eliminates the need for a navigation stack within individual views,
/// thereby preventing unintended back navigation and maintaining a clean navigation hierarchy.
///
/// - Note: `RootView` uses a `ZStack` to overlay views, but only one child view is active at a time.
///   The `.animation` modifier ensures that transitions between views are smooth and visually appealing.
struct RootView: View {
    // MARK: - Properties
    
    /// The `LoadingViewModel` responsible for managing the state during the loading process.
    @StateObject private var loadingViewModel = LoadingViewModel()
    
    /// The `HomeViewModel` responsible for managing the state during the home screen.
    @StateObject private var homeViewModel = HomeViewModel()
    
    /// A computed property that determines the current navigation destination.
    ///
    /// This property prioritizes the navigation state from `LoadingViewModel` if it is active.
    private var currentDestination: AppDestination? {
        homeViewModel.navigationDestination ?? loadingViewModel.navigationDestination
    }
    
    // MARK: - Body
    
    /// The body of the `RootView` which determines which child view to display
    /// based on the current value of `navigationDestination`.
    ///
    /// - Utilizes a `ZStack` to overlay views, allowing for smooth transitions between them.
    /// - Uses a `switch` statement to handle different navigation destinations.
    /// - Applies a transition animation to enhance the user experience during view changes.
    var body: some View {
        ZStack {
            // Determines which view to display based on the current navigation destination
            switch currentDestination {
            case .home:
                // Displays the HomeView when the destination is `.home`
                HomeView(viewModel: homeViewModel)
                    .transition(.opacity) // Applies a fade-in/out transition
                
            case .game(let gameNode):
                // Displays the GameView when the destination is `.game`
                // Passes the required GameNode to GameViewModel
                GameView(viewModel: GameViewModel(gameNode: gameNode))
                    .transition(.opacity) // Applies a fade-in/out transition
                
            case .none:
                // Displays the LoadingView when there is no active navigation destination
                // Typically, this is the initial loading screen
                LoadingView(viewModel: loadingViewModel)
                    .transition(.opacity) // Applies a fade-in/out transition
            }
        }
        // Animates changes to `navigationDestination` with a smooth ease-in-out effect
        .animation(.easeInOut(duration: 0.5), value: loadingViewModel.navigationDestination)
    }
}

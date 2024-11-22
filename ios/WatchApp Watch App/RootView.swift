import SwiftUI

struct RootView: View {
    // Initialize the LoadingViewModel as a StateObject to maintain its lifecycle
    @StateObject private var loadingViewModel = LoadingViewModel()
    
    var body: some View {
        // Conditional rendering based on navigateToHome flag
        if loadingViewModel.navigateToHome {
            // Present HomeView when navigateToHome is true
            HomeView(viewModel: HomeViewModel())
                .transition(.opacity) // Optional: Add transition animation
        } else {
            // Show LoadingView otherwise
            LoadingView(viewModel: loadingViewModel)
                .transition(.opacity) // Optional: Add transition animation
        }
    }
}

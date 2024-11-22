import SwiftUI

/// The `LoadingView` struct is a SwiftUI view that represents the initial loading screen for the app.
/// It displays a background image, an overlay, and a loading indicator while the app fetches the
/// current game node from the iOS app.
///
/// ## Features
/// - Uses a `ZStack` to layer the background image, overlay, and loading indicator.
/// - Reactively updates based on the state of the `LoadingViewModel`.
/// - Calls the `fetchCurrentGameNode` method on `onAppear` to initiate communication with the iOS app.
struct LoadingView: View {
    // MARK: - Properties
    
    /// The view model that manages the logic and state for this view.
    @ObservedObject var viewModel: LoadingViewModel
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background image
                Image("BackgroundImage")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                // Black overlay with 50% opacity
                Color.black
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                
                // Loading indicator and text
                VStack {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white)) // White circular indicator
                        .foregroundColor(.white) // Ensure text and indicator color contrast against the background
                        .fontWeight(.bold) // Emphasize the "Loading..." text
                }
            }
            .onAppear {
                // Initiate fetching the current game node when the view appears.
                viewModel.fetchCurrentGameNode()
            }
            // Navigation Destination for HomeView
            .navigationDestination(isPresented: $viewModel.navigateToHome) {
                HomeView(viewModel: HomeViewModel())
                
            }
            // Handle Errors (Optional)
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "An unknown error occurred."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

import SwiftUI

/// The `HomeView` struct represents the main screen of the app, where the user can start a new game.
/// It provides a button to initiate the game and a consistent background design.
///
/// ## Features
/// - Displays a background image for consistency with the `LoadingView`.
/// - Includes a button labeled "New Game" that triggers the `startNewGame` method in the `HomeViewModel`.
/// - Uses a `ZStack` to layer the background and UI elements, ensuring proper layout.
///
/// ## Behavior
/// - The `viewModel` is an instance of `HomeViewModel`, which manages the logic for starting a new game.
/// - When the "New Game" button is pressed, the view model sends a message to the iOS app to start the game.
struct HomeView: View {
    // MARK: - Properties
    
    /// The view model that manages the logic for this view.
    @ObservedObject var viewModel: HomeViewModel
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background image for visual consistency
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // Main content
            VStack {
                // Title text
                Text("Start a New Game")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                
                // "New Game" button
                Button(action: {
                    // Trigger the `startNewGame` method in the view model
                    viewModel.startNewGame()
                }) {
                    Text("New Game")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity) // Button stretches horizontally
                        .background(Color.blue) // Blue background
                        .foregroundColor(.white) // White text for contrast
                        .cornerRadius(8) // Rounded corners for a polished look
                }
                .padding(.horizontal) // Add horizontal padding for layout alignment
            }
        }
    }
}

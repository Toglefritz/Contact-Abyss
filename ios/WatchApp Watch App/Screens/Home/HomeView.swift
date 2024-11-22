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
                .ignoresSafeArea() // Updated for SwiftUI's latest API
            
            // Black overlay with 50% opacity
            Color.black
                .opacity(0.6)
                .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 20) { // Added spacing for better layout
                // Title text
                Text("Contact\nAbyss")
                    .font(Font.custom("Kode Mono", size: 28)) // Custom font
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center) // Center alignment
                    .lineLimit(nil) // Allow unlimited lines
                    .padding(.horizontal, 10) // Horizontal padding to prevent overflow
                    // Glowing shadow layers
                    .shadow(color: Color.white.opacity(0.8), radius: 1, x: 0, y: 0)
                    .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 0)
                
                // "New Game" button
                Button(action: {
                    // Trigger the `startNewGame` method in the view model
                    viewModel.startNewGame()
                }) {
                    Text("New Game")
                    
                        .font(Font.custom("Kode Mono", size: 18)) // Custom font
                        .foregroundColor(.white) // White text for contrast
                        .padding(.horizontal, 16) // Padding inside the button
                        .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle()) // Remove default button styling
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 1.5)
                )
                .background(Color.clear)
                .cornerRadius(12)
                .padding(.horizontal, 10)
            }
        }
    }
}

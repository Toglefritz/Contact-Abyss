import SwiftUI

/// The `GameView` struct represents the main gameplay interface in the app.
/// It displays the current game node's story text and the choices available to the player.
///
/// ## Features
/// - Displays a background image for visual consistency with other views.
/// - Shows the story text for the current game node.
/// - Lists available choices as buttons, allowing the user to progress through the game.
/// - Uses a `ScrollView` to accommodate varying amounts of content.
///
/// ## Behavior
/// - Reactively updates based on changes to the `GameViewModel`.
/// - When a choice button is tapped, the view model's `selectChoice` method is called, sending the selected choice to the iOS app.
///
/// ## Design
/// - Background image and white text maintain a cohesive visual theme.
/// - Choice buttons are styled with a green background and rounded corners for emphasis.
struct GameView: View {
    // MARK: - Properties
    
    /// The view model that manages the logic and state for this view.
    @ObservedObject var viewModel: GameViewModel
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background image for visual consistency
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // Black overlay with 50% opacity
            Color.black
                .opacity(0.8)
                .ignoresSafeArea()
            
            // Main content in a scrollable container
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Story text for the current game node
                    Text(viewModel.gameNode.storyText)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    
                    // Buttons for available choices
                    ForEach(viewModel.gameNode.choices) { choice in
                        Button(action: {
                            // Handle the selection of a choice
                            viewModel.selectChoice(choice)
                        }) {
                            Text("1>" + choice.choiceText)
                                .font(Font.custom("Kode Mono", size: 18)) // Custom font
                                .foregroundColor(.clear) // White text for contrast
                                .padding(.horizontal, 24) // Padding inside the button
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity) // Stretch button horizontally
                                .background(Color.clear) // Green background for emphasis
                                .cornerRadius(8) // Rounded corners for a polished look
                        }
                    }
                }
                .padding() // Add padding around the content
            }
        }
        .onAppear {
            // Trigger any additional setup when the view appears
        }
    }
}

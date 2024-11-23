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
            
            // Black overlay with 50% opacity for better text readability
            Color.black
                .opacity(0.8)
                .ignoresSafeArea()
            
            // Main content in a scrollable container
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Story text for the current game node
                    Text(viewModel.gameNode.storyText)
                        .font(Font.custom("Kode Mono", size: 14))
                        .foregroundColor(.white)
                    
                    // Buttons for available choices, styled as text-only buttons
                    ForEach(Array(viewModel.gameNode.choices.enumerated()), id: \.1.id) { index, choice in
                        Button(action: {
                            // Handle the selection of a choice
                            viewModel.selectChoice(choice)
                        }) {
                            Text("\(index + 1) > \(choice.choiceText)")
                                .font(Font.custom("Kode Mono", size: 11)) // Custom font
                                .foregroundColor(.white)
                                .padding(.horizontal, 8) // Horizontal padding inside the button
                                .frame(maxWidth: .infinity, alignment: .leading) // Stretch button horizontally, align text to leading
                        }
                        .buttonStyle(PlainButtonStyle()) // Remove default button styles
                        .contentShape(Rectangle()) // Expand tap area to the entire button frame
                    }
                }
                .padding(.all, 42) // Add padding around the content
            }
        }
    }
}

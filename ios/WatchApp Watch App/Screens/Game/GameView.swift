import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            Image("BackgroundImage") // Maintain visual consistency
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(viewModel.gameNode.storyText)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                    
                    ForEach(viewModel.gameNode.choices) { choice in
                        Button(action: {
                            viewModel.selectChoice(choice)
                        }) {
                            Text(choice.choiceText)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            // Additional setup if needed
        }
    }
}

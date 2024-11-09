import SwiftUI

struct LoadingView: View {
    @ObservedObject var viewModel: LoadingViewModel
    
    var body: some View {
        ZStack {
            // Background image
            Image("BackgroundImage")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // Black overlay with 50% opacity
            Color.black
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            // Loading indicator and text
            VStack {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .fontWeight(.bold)  
            }
        }
        .onAppear {
            viewModel.fetchCurrentGameNode()
        }
    }
}

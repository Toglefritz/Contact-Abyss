import SwiftUI

/// The `WatchApp_Watch_AppApp` struct serves as the entry point for the WatchOS companion application.
///
/// ## Overview
/// This struct conforms to the `App` protocol, which defines the main structure and lifecycle of the application.
/// It is responsible for setting up the initial user interface and defining the app's primary scene. In this case,
/// the app begins with the `LoadingView`, which manages the initial communication with the iOS app and determines
/// whether the user is presented with the current game state or the option to start a new game.
///
/// ## Key Features
/// - The app initializes with a `WindowGroup` scene containing the `LoadingView`.
/// - A custom font (`Kode Mono`) is applied globally to enhance the user interface aesthetics.
/// - The `LoadingViewModel` is passed as a dependency to the `LoadingView`, enabling the view to manage
///   the app's logic for fetching the current game node and updating the UI accordingly.
///
/// ## Lifecycle
/// When the WatchOS app is launched, this struct initializes the SwiftUI app and loads the `LoadingView`.
/// The `LoadingViewModel` handles communication with the iOS app to determine the user's current game state.
/// Depending on the response, the app navigates to either the active game node or a screen prompting the user
/// to start a new game.
@main
struct WatchApp_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

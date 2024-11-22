/// An enumeration representing the various destinations or screens within the WatchOS app.
///
/// This enum serves as a centralized list of all possible navigation targets in the app.
/// By using an enum, navigation becomes more manageable and less error-prone,
/// especially as the app scales and more destinations are added.
///
/// - `home`: Represents the Home screen of the app where users can start or continue their game.
/// - `settings`: Represents the Settings screen where users can adjust app preferences.
/// - `profile`: Represents the Profile screen where users can view and edit their profile information.
/// - Additional cases can be added here to represent new screens or functionalities as the app evolves.
enum AppDestination: Equatable {
    case home
    case game(GameNode) 
}

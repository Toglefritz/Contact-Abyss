import Foundation

/// An enumeration of possible outcomes of a game.
enum GameOutcome: String, Codable, Identifiable {
    /// The player has won the game.
    case win = "win"

    /// The player has lost the game.
    case loss = "loss"

    /// The game has ended without a definitive win or loss outcome.
    case neutral = "neutral"

    /// An identifier for the GameOutcome.
    var id: String { self.rawValue }
}

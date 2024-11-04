/// An enumeration of possible outcomes of a game.
enum GameOutcome {
  /// The player has won the game.
  win('win'),

  /// The player has lost the game.
  loss('loss'),

  /// The game has ended without a definitive win or loss outcome.
  neutral('neutral');

  /// An identifier for the [GameOutcome] in the game data.
  final String id;

  /// Creates a new instance of [GameOutcome].
  const GameOutcome(this.id);
}

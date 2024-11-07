
/// A class representing a choice available to the player at a specific game node.
///
/// Each `Choice` includes the text displayed to the player and the target node's
/// unique identifier that the game will navigate to upon selection.
class Choice {
  /// The text of the choice presented to the player.
  final String choiceText;

  /// The unique identifier of the target `GameNode` this choice leads to.
  final String target;

  /// Creates a new instance of [Choice].
  ///
  /// - [choiceText]: The text displayed for this choice.
  /// - [target]: The ID of the node that this choice navigates to.
  Choice({
    required this.choiceText,
    required this.target,
  });

  /// Creates a [Choice] instance from a JSON map.
  ///
  /// This factory constructor is useful for deserializing JSON data into
  /// `Choice` objects.
  ///
  /// - [json]: A `Map<String, dynamic>` containing the choice's data.
  ///
  /// Returns a new instance of [Choice].
  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      choiceText: json['choice_text'] as String,
      target: json['target'] as String,
    );
  }

  /// Converts the [Choice] instance into a JSON map.
  ///
  /// This method is useful for serializing `Choice` objects into JSON format.
  ///
  /// Returns a `Map<String, dynamic>` representing the choice's data.
  Map<String, dynamic> toJson() {
    return {
      'choice_text': choiceText,
      'target': target,
    };
  }
}

import 'package:contact_abyss/services/game_service/models/choice.dart';
import 'package:contact_abyss/services/game_service/models/game_outcome.dart';
import 'package:contact_abyss/services/game_service/models/sensor_data.dart';

/// A class representing a single node in the "Contact Abyss" game.
///
/// Each `GameNode` contains the narrative text, sensor data, available choices, battery power changes, and
/// information about whether the node signifies the end of the game. This structure allows for the creation of an
/// n-ary tree that models the game's decision-making process.
class GameNode {
  /// A unique identifier for the node.
  final String id;

  /// The narrative text displayed to the player at this node.
  final String storyText;

  /// Optional sensor data associated with this node.
  ///
  /// This may include information such as battery level, radiation levels,
  /// and other environmental readings that influence the player's decisions.
  final SensorData? sensorData;

  /// A list of choices available to the player at this node.
  ///
  /// Each choice leads to another `GameNode` identified by its target ID.
  final List<Choice> choices;

  /// The change in battery power resulting from the player's decision at this node.
  ///
  /// A positive value indicates a gain in battery power, while a negative value
  /// signifies a loss. This helps manage the battery constraints within the game.
  final int? batteryChange;

  /// Indicates whether this node is an ending point of the game.
  ///
  /// If `true`, the game concludes upon reaching this node.
  final bool isEnd;

  /// Determines if the game outcome is a win, loss, or neutral. A [GameOutcome] will only be available for ending
  /// nodes.
  final GameOutcome? outcome;

  /// Creates a new instance of [GameNode].
  ///
  /// - [id]: A unique identifier for the node.
  /// - [storyText]: The narrative text displayed to the player.
  /// - [choices]: A list of available choices at this node.
  /// - [sensorData]: Optional sensor data related to the node.
  /// - [batteryChange]: Optional change in battery power.
  /// - [isEnd]: Optional flag indicating if this node is an ending point.
  GameNode({
    required this.id,
    required this.storyText,
    required this.choices,
    this.sensorData,
    this.batteryChange,
    this.isEnd = false,
    this.outcome,
  });

  /// Creates a [GameNode] instance from a JSON map.
  ///
  /// This factory constructor is useful for deserializing JSON data into
  /// `GameNode` objects.
  ///
  /// - [json]: A `Map<String, dynamic>` containing the node's data.
  ///
  /// Returns a new instance of [GameNode].
  factory GameNode.fromJson(Map<String, dynamic> json) {
    return GameNode(
      id: json['id'] as String,
      storyText: json['story_text'] as String,
      sensorData: json['sensor_data'] != null ? SensorData.fromJson(json['sensor_data'] as Map<String, dynamic>) : null,
      choices: (json['choices'] as List<dynamic>? ?? [])
          .map((choice) => Choice.fromJson(choice as Map<String, dynamic>))
          .toList(),
      batteryChange: json['battery_change'] != null ? json['battery_change'] as int : null,
      isEnd: json['is_end'] as bool? ?? false,
      outcome: json['outcome'] != null
          ? GameOutcome.values.firstWhere((outcome) => outcome.id == json['outcome'] as String)
          : null,
    );
  }

  /// Converts the [GameNode] instance into a JSON map.
  ///
  /// This method is useful for serializing `GameNode` objects into JSON format.
  ///
  /// Returns a `Map<String, dynamic>` representing the node's data.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'story_text': storyText,
      if (sensorData != null) 'sensor_data': sensorData!.toJson(),
      'choices': choices.map((choice) => choice.toJson()).toList(),
      if (batteryChange != null) 'battery_change': batteryChange,
      'is_end': isEnd,
    };
  }
}

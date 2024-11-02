import 'dart:convert';

import 'package:contact_abyss/services/game_service/models/choice.dart';
import 'package:contact_abyss/services/game_service/models/game_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A service class responsible for managing the game data n-ary tree and tracking the player's progress through the game.
///
/// This service handles parsing the JSON game data file to construct the n-ary tree of [GameNode]s and provides
/// methods to navigate through the game based on player decisions.
class GameDataService {
  /// A map of node IDs to their corresponding [GameNode] instances.
  ///
  /// This map represents the entire game structure, allowing quick access to any node using its unique identifier.
  final Map<String, GameNode> _nodes = {};

  /// The current [GameNode] the player is on.
  ///
  /// This property tracks the player's current position within the game. Storing the `id` of the current node allows
  /// the player's progress through the game to be saved so that they can resume from where they left off.
  GameNode? _currentNode;

  /// A history of node IDs representing the path the player has taken.
  ///
  /// This list can be used for features like undoing moves or reviewing the player's journey through the game.
  final List<String> _history = [];

  /// The current battery level of the probe, represented as a percentage.
  ///
  /// This value decreases or increases based on the player's decisions. The battery level must be managed to ensure
  /// mission success.
  int _batteryLevel = 100;

  /// Creates an instance of [GameDataService].
  ///
  /// Initializes the service without any loaded game data. Use [_loadGameFromJson] or [loadGameFromAsset] to populate
  /// the game tree.
  GameDataService();

  /// Loads the game data from a JSON string and constructs the n-ary tree.
  ///
  /// This method parses the provided [jsonString], creates [GameNode] instances for each node in the JSON, and links
  /// the choices to their respective target nodes. After loading, the current node is set to the node with ID
  /// `'start'`.
  ///
  /// If the game data is malformed or is missing nodes, this method throws a [FormatException].
  Future<void> _loadGameFromJson(String jsonString) async {
    try {
      // Parse the JSON string and extract the nodes list.
      final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
      // Get the list of nodes from the JSON data.
      final List<dynamic> nodesJson = jsonData['nodes'] as List<dynamic>;

      // First pass: Create all GameNode instances and store them in the map.
      for (final dynamic nodeJson in nodesJson) {
        try {
          // Create a GameNode instance from the JSON data.
          final GameNode node = GameNode.fromJson(nodeJson as Map<String, dynamic>);
          // Store the node in the map using its ID as the key.
          _nodes[node.id] = node;
        } catch (e) {
          throw FormatException('Failed to parse node with JSON, $nodeJson, with exception, $e');
        }
      }

      // Second pass: Validate that all target nodes exist by ensuring that each choice's target is a valid node ID.
      for (final GameNode node in _nodes.values) {
        for (final Choice choice in node.choices) {
          if (!_nodes.containsKey(choice.target)) {
            throw FormatException(
              "Target node '${choice.target}' not found for choice '${choice.choiceText}' in node '${node.id}'.",
            );
          }
        }
      }

      // Set the current node to the start node. Initialize the history with the start node ID.
      _currentNode = _nodes['start'];
      _history
        ..clear()
        ..add('start');

      // Initialize battery level from the start node's sensor data, if available.
      if (_currentNode!.sensorData != null) {
        _batteryLevel = _currentNode!.sensorData!.batteryLevel;
      } else {
        _batteryLevel = 100; // Default battery level
      }
    } catch (e) {
      throw FormatException('Failed to load game data: $e');
    }
  }

  /// Loads the game data from a JSON asset file and constructs the n-ary tree.
  ///
  /// This method reads the JSON file located at [assetPath], parses its content, creates [GameNode] instances for
  /// each node, and links the choices to their respective target nodes. After loading, the current node is set to the
  /// node with ID `'start'`.
  ///
  /// If the game data is malformed or is missing nodes, this method throws a [FormatException].
  Future<void> loadGameFromAsset(String assetPath) async {
    final String jsonString;
    try {
      jsonString = await rootBundle.loadString(assetPath);
    } catch (e) {
      throw FlutterError('Failed to load game asset with exception, $e');
    }

    try {
      await _loadGameFromJson(jsonString);
    } catch (e, s) {
      throw FlutterError('Failed to load game data with exception, $e; $s');
    }
  }

  /// Retrieves the current [GameNode] the player is on.
  ///
  /// Returns `null` if no game is loaded.
  GameNode? get currentNode => _currentNode;

  /// Retrieves the history of node IDs representing the player's path.
  ///
  /// This list can be used to review the player's journey or implement features like undoing moves.
  List<String> get history => List.unmodifiable(_history);

  /// Retrieves the current battery level of the probe.
  ///
  /// Returns the battery level as an integer percentage.
  int get batteryLevel => _batteryLevel;

  /// Makes a choice based on the provided [choiceIndex] from the current node.
  ///
  /// This method updates the current node to the target node associated with the selected choice. It also updates the
  /// player's history and adjusts the battery level based on the choice's `batteryChange`.
  ///
  /// This method returns `true` if the choice was successfully made and the game state was updated. If the choice index
  /// is invalid or the current node is `null`, this method returns `false`.
  bool makeChoice(int choiceIndex) {
    // Check if the current node is valid.
    if (_currentNode == null) {
      return false;
    }

    // Check if the choice index is valid.
    if (choiceIndex < 0 || choiceIndex >= _currentNode!.choices.length) {
      return false;
    }

    // Retrieve the selected choice and its target node.
    final Choice selectedChoice = _currentNode!.choices[choiceIndex];
    // Find the target node corresponding to the selected choice.
    final GameNode? targetNode = _nodes[selectedChoice.target];

    // Check if the target node exists. If not, return false.
    if (targetNode == null) {
      return false;
    }

    // Update battery level if the target node has a battery change.
    if (targetNode.batteryChange != null) {
      _batteryLevel += targetNode.batteryChange!;
      // Ensure battery level stays within 0-100%
      if (_batteryLevel > 100) _batteryLevel = 100;
      if (_batteryLevel < 0) _batteryLevel = 0;
    }

    // Update the current node and history.
    _currentNode = targetNode;
    _history.add(targetNode.id);

    return true;
  }

  /// Resets the game to the initial start node.
  ///
  /// This method clears the player's history and sets the current node back to the node with ID `'start'`. It also resets the battery level.
  void resetGame() {
    _currentNode = _nodes['start'];
    _history
      ..clear()
      ..add('start');

    // Reset battery level from the start node's sensor data, if available.
    if (_currentNode!.sensorData != null) {
      _batteryLevel = _currentNode!.sensorData!.batteryLevel;
    } else {
      _batteryLevel = 100; // Default battery level
    }
  }

  /// Retrieves a [GameNode] by its unique [nodeId].
  GameNode? getNodeById(String nodeId) {
    return _nodes[nodeId];
  }

  /// Checks whether the game has reached an end node.
  ///
  /// An end node signifies the conclusion of the game, either through mission success or failure.
  bool isEndNode() {
    return _currentNode?.isEnd ?? false;
  }

  /// Retrieves the total number of nodes in the game.
  int get totalNodes => _nodes.length;

  /// Retrieves all available choices from the current node.
  List<Choice> getAvailableChoices() {
    return _currentNode?.choices ?? [];
  }

  /// Determines if the probe has sufficient battery to continue the mission.
  ///
  /// This method returns `true` if the battery level is greater than 0, indicating that the probe can continue its
  /// mission. If the battery level reaches 0, the mission is considered a failure, and this method returns `false`.
  bool canContinue() {
    return _batteryLevel > 0;
  }
}

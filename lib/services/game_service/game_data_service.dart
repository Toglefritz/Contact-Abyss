import 'dart:convert';

import 'package:contact_abyss/services/game_service/models/choice.dart';
import 'package:contact_abyss/services/game_service/models/game_node.dart';
import 'package:contact_abyss/services/watch_os_communication/watch_os_communication_service.dart';
import 'package:contact_abyss/services/watch_os_communication/watch_os_communication_service_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A service class responsible for managing the game data n-ary tree and tracking the player's progress through the game.
///
/// This service handles parsing the JSON game data file to construct the n-ary tree of [GameNode]s and provides
/// methods to navigate through the game based on player decisions.
class GameDataService with ChangeNotifier {
  /// The single instance of [GameDataService].
  ///
  /// This static property ensures that only one instance of [GameDataService] exists throughout the lifecycle of the
  /// app.
  static final GameDataService _instance = GameDataService._internal();

  /// Factory constructor that returns the singleton instance.
  factory GameDataService() {
    return _instance;
  }

  /// A private named constructor to prevent external instantiation.
  GameDataService._internal();

  /// A map of node IDs to their corresponding [GameNode] instances.
  ///
  /// This map represents the entire game structure, allowing quick access to any node using its unique identifier.
  final Map<String, GameNode> _nodes = {};

  /// The current [GameNode] the player is on.
  ///
  /// This property tracks the player's current position within the game. Storing the `id` of the current node allows
  /// the player's progress through the game to be saved so that they can resume from where they left off. This
  /// member is implemented as a [ValueNotifier] to notify listeners when the current node changes.
  ValueNotifier<GameNode?> currentNode = ValueNotifier<GameNode?>(null);

  /// A history of node IDs representing the path the player has taken.
  ///
  /// This list can be used for features like undoing moves or reviewing the player's journey through the game.
  final List<String> _history = [];

  /// Retrieves the history of node IDs representing the player's path.
  ///
  /// This list can be used to review the player's journey or implement features like undoing moves.
  List<String> get history => List.unmodifiable(_history);

  /// The current battery level of the probe, represented as a percentage.
  ///
  /// This value decreases or increases based on the player's decisions. The battery level must be managed to ensure
  /// mission success.
  int _batteryLevel = 100;

  /// Retrieves the current battery level of the probe.
  ///
  /// Returns the battery level as an integer percentage.
  int get batteryLevel => _batteryLevel;

  /// Determines if the game data has been loaded by checking if the list of nodes is not empty.
  bool get isGameLoaded => _nodes.isNotEmpty;

  /// A [WatchOSCommunicationService] instance used to communicate with the WatchOS app.
  final WatchOSCommunicationService _communicationService = WatchOSCommunicationService();

  /// Loads the game data from a JSON asset file and constructs the n-ary tree. The game data is cached in the [_nodes]
  /// list so it can be accessed synchronously.
  ///
  /// This method reads a JSON file, parses its content, creates [GameNode] instances for each node, and links the
  /// choices to their respective target nodes. After loading, the current node is set to the node with ID `'start'`.
  ///
  /// If the game data is malformed or is missing nodes, this method throws a [FormatException].
  Future<void> loadGameData() async {
    // First, load the JSON string from the asset file.
    final String jsonString;
    try {
      jsonString = await rootBundle.loadString('assets/game_data/game_data.json');
    } catch (e) {
      throw FlutterError('Failed to load game asset with exception, $e');
    }

    // Then, parse the JSON string and construct the game tree.
    try {
      await _loadGameFromJson(jsonString);
    } catch (e, s) {
      throw FlutterError('Failed to load game data with exception, $e; $s');
    }
  }

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

      // Third pass: Validate that all ending nodes have an outcome.
      for (final GameNode node in _nodes.values) {
        if (node.isEnd && node.outcome == null) {
          throw FormatException("Ending node '${node.id}' does not have an outcome.");
        }
      }
    } catch (e) {
      throw FormatException('Failed to load game data: $e');
    }
  }

  /// Starts a new game.
  ///
  /// This method resets the game state to the initial start node and sets the battery level to 100%.
  void startNewGame() {
    _history
      ..clear()
      ..add('start');

    // Reset battery level to 100%.
    _batteryLevel = 100;

    currentNode
      ..value = _nodes['start']
      ..notifyListeners();

    // Send the new game node to the WatchOS app.
    _onGameNodeChanged();
  }

  /// Stops the current game.
  ///
  /// This method stops the game by setting the current node to null, clearing the player's history, and setting the
  /// battery level to 100%.
  void stopGame() {
    currentNode
      ..value = null
      ..notifyListeners();

    // Send a null value as the game node to the WatchOS app to indicate that the game has ended.
    _onGameNodeChanged();

    _history.clear();
    _batteryLevel = 100;
  }

  /// Makes a choice based on the provided [choiceIndex] from the current node.
  ///
  /// This method updates the current node to the target node associated with the selected choice. It also updates the
  /// player's history and adjusts the battery level based on the choice's `batteryChange`.
  ///
  /// This method returns `true` if the choice was successfully made and the game state was updated. If the choice index
  /// is invalid or the current node is `null`, this method returns `false`.
  bool makeChoice(int choiceIndex) {
    // Check if the current node is valid.
    if (currentNode.value == null) {
      return false;
    }

    // Check if the choice index is valid.
    if (choiceIndex < 0 || choiceIndex >= currentNode.value!.choices.length) {
      return false;
    }

    // Retrieve the selected choice and its target node.
    final Choice selectedChoice = currentNode.value!.choices[choiceIndex];
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
    currentNode
      ..value = targetNode
      ..notifyListeners();

    // Send the new game node to the WatchOS app.
    _onGameNodeChanged();

    _history.add(targetNode.id);

    return true;
  }

  /// Retrieves a [GameNode] by its unique [nodeId].
  GameNode? getNodeById(String nodeId) {
    return _nodes[nodeId];
  }

  /// Checks whether the game has reached an end node.
  ///
  /// An end node signifies the conclusion of the game, either through mission success or failure.
  bool isEndNode() {
    return currentNode.value?.isEnd ?? false;
  }

  /// Retrieves the total number of nodes in the game.
  int get totalNodes => _nodes.length;

  /// Retrieves all available choices from the current node.
  List<Choice> getAvailableChoices() {
    return currentNode.value?.choices ?? [];
  }

  /// Determines if the probe has sufficient battery to continue the mission.
  ///
  /// This method returns `true` if the battery level is greater than 0, indicating that the probe can continue its
  /// mission. If the battery level reaches 0, the mission is considered a failure, and this method returns `false`.
  bool canContinue() {
    return _batteryLevel > 0;
  }

  /// When the game node changes, send the new game node to the WatchOS app.
  ///
  /// This method is called when the current game node changes. It sends the new game node to the WatchOS app so it can
  /// update the game state on the watch. This enables the WatchOS app and the Flutter app to stay in sync during the
  /// game.
  void _onGameNodeChanged() {
    final GameNode? gameNode = currentNode.value;

    if (gameNode != null) {
      try {
        debugPrint('Sending game node to WatchOS app: ${gameNode.id}');
        _communicationService.sendGameNode(gameNode);
      } catch (e) {
        debugPrint('Failed to send game node to WatchOS app: $e');

        // TODO(Toglefritz): Handle the error
      }
    }
  }
}

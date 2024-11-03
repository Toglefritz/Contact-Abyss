import 'package:contact_abyss/screens/game/home_controller.dart';
import 'package:contact_abyss/services/game_service/game_data_service.dart';
import 'package:flutter/material.dart';

/// The [GameRoute[ is the interface through which the player interacts with the game. It displays the game's current
/// state and allows the player to make decisions that affect the game's outcome.
///
/// This route always displays the current game node. When the player makes a decision, the game controller updates the
/// game state and displays the new node.
///
/// If a node includes an image, it is displayed as a background element behind the text and choice widgets. If the
/// node includes a sound effect, it is played when the node is displayed.
class GameRoute extends StatefulWidget {
  /// Creates a new instance of [GameRoute].
  const GameRoute({
    required this.gameDataService,
    super.key,
  });

  /// A [GameDataService] instance that provides access to the game data. In this controller, the service is used to
  /// get information about the current game state and update the game state based on player decisions. This route
  /// assumes that the game data has already been loaded.
  final GameDataService gameDataService;

  @override
  GameController createState() => GameController();
}

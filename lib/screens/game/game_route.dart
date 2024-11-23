import 'package:contact_abyss/screens/game/game_controller.dart';
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
  const GameRoute({super.key});

  @override
  GameController createState() => GameController();
}

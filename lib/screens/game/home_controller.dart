import 'package:contact_abyss/screens/game/home_route.dart';
import 'package:contact_abyss/screens/game/home_view.dart';
import 'package:contact_abyss/screens/home/home_route.dart';
import 'package:contact_abyss/services/game_service/models/game_node.dart';
import 'package:flutter/material.dart';

/// A controller for the [GameRoute].
class GameController extends State<GameRoute> {
  /// A convenience getter for the current game node.
  GameNode get gameNode => widget.gameDataService.currentNode!;

  /// Called when the user choose a choice from a game node.
  void makeChoice(int choiceIndex) {
    // TODO(Toglefritz): Confirm choice

    setState(() {
      widget.gameDataService.makeChoice(choiceIndex);
    });
  }

  /// Resets the game back to the start.
  void resetGame() {
    setState(() {
      widget.gameDataService.resetGame();
    });
  }

  /// Returns the user to the main menu.
  void returnToMainMenu() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => const HomeRoute(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => GameView(this);
}

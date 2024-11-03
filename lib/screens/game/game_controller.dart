import 'package:contact_abyss/screens/game/game_route.dart';
import 'package:contact_abyss/screens/game/game_view.dart';
import 'package:contact_abyss/screens/home/home_route.dart';
import 'package:contact_abyss/services/game_service/models/game_node.dart';
import 'package:flutter/material.dart';

/// A controller for the [GameRoute].
class GameController extends State<GameRoute> {
  /// A convenience getter for the current game node.
  GameNode get gameNode => widget.gameDataService.currentNode!;

  /// A convenience getter for the current battery level.
  int get batteryLevel => widget.gameDataService.batteryLevel;

  /// Returns an [Icon] to be used to indicate the remaining battery level.
  Icon get batteryIcon {
    if (batteryLevel < 12.5) {
      return const Icon(
        Icons.battery_0_bar,
        size: 36,
      );
    } else if (batteryLevel < 25) {
      return const Icon(
        Icons.battery_1_bar,
        size: 36,
      );
    } else if (batteryLevel < 37.5) {
      return const Icon(
        Icons.battery_2_bar,
        size: 36,
      );
    } else if (batteryLevel < 50) {
      return const Icon(
        Icons.battery_3_bar,
        size: 36,
      );
    } else if (batteryLevel < 62.5) {
      return const Icon(
        Icons.battery_4_bar,
        size: 36,
      );
    } else if (batteryLevel < 75) {
      return const Icon(
        Icons.battery_5_bar,
        size: 36,
      );
    } else if (batteryLevel < 87.5) {
      return const Icon(
        Icons.battery_6_bar,
        size: 36,
      );
    } else {
      return const Icon(
        Icons.battery_full,
        size: 36,
      );
    }
  }

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

import 'package:contact_abyss/screens/game/game_route.dart';
import 'package:contact_abyss/screens/game/game_view.dart';
import 'package:contact_abyss/screens/home/home_route.dart';
import 'package:contact_abyss/services/game_service/models/game_node.dart';
import 'package:contact_abyss/services/game_service/models/game_outcome.dart';
import 'package:flutter/material.dart';

/// A controller for the [GameRoute].
class GameController extends State<GameRoute> {
  /// A convenience getter for the current game node.
  GameNode get gameNode => widget.gameDataService.currentNode!;

  /// A convenience getter for the current battery level.
  int get batteryLevel => widget.gameDataService.batteryLevel;

  /// Returns an [IconData] to be used to indicate the remaining battery level.
  IconData get batteryIcon {
    if (batteryLevel < 12.5) {
      return Icons.battery_0_bar;
    } else if (batteryLevel < 25) {
      return Icons.battery_1_bar;
    } else if (batteryLevel < 37.5) {
      return Icons.battery_2_bar;
    } else if (batteryLevel < 50) {
      return Icons.battery_3_bar;
    } else if (batteryLevel < 62.5) {
      return Icons.battery_4_bar;
    } else if (batteryLevel < 75) {
      return Icons.battery_5_bar;
    } else if (batteryLevel < 87.5) {
      return Icons.battery_6_bar;
    } else {
      return Icons.battery_full;
    }
  }

  /// Returns an image to use for a [GameOutcome].
  String getOutcomeImage() {
    final GameOutcome outcome = gameNode.outcome!;

    switch (outcome) {
      case GameOutcome.win:
        return 'assets/outcome_images/win.png';
      case GameOutcome.loss:
        return 'assets/outcome_images/loss.png';
      case GameOutcome.neutral:
        return 'assets/outcome_images/neutral.png';
    }
  }

  /// Returns text to display based on the game outcome.
  String getOutcomeText() {
    final GameOutcome outcome = gameNode.outcome!;

    switch (outcome) {
      case GameOutcome.win:
        return 'Congratulations! The data transmitted back to Earth represents one of the most significant scientific discoveries in human history.';
      case GameOutcome.loss:
        return 'Game Over. Your mission has failed.';
      case GameOutcome.neutral:
        return 'Your mission has ended. The data you managed to transmit is of immense scientific value, but the full story remains untold.';
    }
  }

  /// Called when the user choose a choice from a game node.
  void makeChoice(int choiceIndex) {
    setState(() {
      widget.gameDataService.makeChoice(choiceIndex);
    });
  }

  /// Resets the game back to the start.
  void resetGame() {
    // TODO(Toglefritz): Confirm choice to reset game

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

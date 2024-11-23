import 'package:contact_abyss/screens/game/game_route.dart';
import 'package:contact_abyss/screens/game/game_view.dart';
import 'package:contact_abyss/screens/home/home_route.dart';
import 'package:contact_abyss/services/game_service/game_data_service.dart';
import 'package:contact_abyss/services/game_service/models/game_node.dart';
import 'package:contact_abyss/services/game_service/models/game_outcome.dart';
import 'package:flutter/material.dart';

/// A controller for the [GameRoute].
class GameController extends State<GameRoute> {
  /// A [GameDataService] instance that provides access to the game data. In this controller, the service is used to
  /// get information about the current game state and update the game state based on player decisions. This route
  /// assumes that the game data has already been loaded.
  final GameDataService gameDataService = GameDataService();

  @override
  void initState() {
    // Listen to changes in the current game node from actions performed on the WatchOS app.
    gameDataService.currentNode.addListener(_onGameNodeChanged);

    super.initState();
  }

  /// A convenience getter for the current game node.
  GameNode get gameNode => gameDataService.currentNode.value!;

  /// A convenience getter for the current battery level.
  int get batteryLevel => gameDataService.batteryLevel;

  /// Handles changes to the current game node.
  void _onGameNodeChanged() => setState(() {});

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
      gameDataService.makeChoice(choiceIndex);
    });
  }

  /// Resets the game back to the start.
  void resetGame() {
    // TODO(Toglefritz): Confirm choice to reset game

    setState(gameDataService.startNewGame);
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

  @override
  void dispose() {
    // Stop listening to changes in the current game node.
    gameDataService.currentNode.removeListener(_onGameNodeChanged);

    // Stop the game.
    gameDataService.stopGame();

    super.dispose();
  }
}

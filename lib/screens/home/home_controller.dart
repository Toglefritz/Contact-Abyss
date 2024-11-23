import 'package:contact_abyss/screens/game/game_route.dart';
import 'package:contact_abyss/screens/home/home_route.dart';
import 'package:contact_abyss/screens/home/home_view.dart';
import 'package:contact_abyss/services/game_service/game_data_service.dart';
import 'package:flutter/material.dart';

/// A controller for the [HomeRoute].
class HomeController extends State<HomeRoute> {
  /// A [GameDataService] instance that provides access to the game data. In this controller, the service is used
  /// to initialize the game data so the player can start a new game or load a saved game.
  final GameDataService gameDataService = GameDataService();

  @override
  void initState() {
    // Initialize the game data.
    _initializeGameData();

    // TODO(Toglefritz): load saved games

    // Listen for changes in the current game node triggered from a new game being started from the WatchOS app.
    gameDataService.currentNode.addListener(_onCurrentNodeChanged);

    super.initState();
  }

  /// Initializes the game data by loading it from a JSON file saved in the assets folder. This game data determines
  /// the tree of decision points a player will traverse during the game.
  Future<void> _initializeGameData() async {
    // Load the game data from the JSON file.
    await gameDataService.loadGameData();

    setState(() {});
  }

  /// Handles changes to the current game node.
  void _onCurrentNodeChanged() {
    // If the current node is null, the game has ended.
    if (gameDataService.currentNode.value != null) {
      _navigateToGame();
    }
  }

  /// Handles taps on the "New Game" button.
  Future<void> onNewGame() async => gameDataService.startNewGame();

  /// Navigates to the [GameRoute] to begin a new game.
  void _navigateToGame() {
    // Remove the listener to prevent memory leaks.
    gameDataService.currentNode.removeListener(_onCurrentNodeChanged);

    // Navigate to the game route.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const GameRoute(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => HomeView(this);

  @override
  void dispose() {
    gameDataService.currentNode.removeListener(_onCurrentNodeChanged);
    super.dispose();
  }
}

import 'package:contact_abyss/screens/home/home_route.dart';
import 'package:contact_abyss/screens/home/home_view.dart';
import 'package:contact_abyss/services/game_service/game_data_service.dart';
import 'package:flutter/material.dart';

/// A controller for the [HomeRoute].
class HomeController extends State<HomeRoute> {
  /// A [GameDataService] instance that provides access to the game data. In this controller, the service is used
  /// to initialize the game data so the player can start a new game or load a saved game.
  final GameDataService _gameDataService = GameDataService();

  @override
  void initState() {
    // Initialize the game data.
    _initializeGameData();

    super.initState();
  }

  /// Initializes the game data by loading it from a JSON file saved in the assets folder. This game data determines
  /// the tree of decision points a player will traverse during the game.
  Future<void> _initializeGameData() async {
    // Load the game data from the JSON file.
    await _gameDataService.loadGameFromAsset('assets/game_data/game_data.json');
  }

  @override
  Widget build(BuildContext context) => HomeView(this);
}

import 'package:contact_abyss/screens/home/home_controller.dart';
import 'package:flutter/material.dart';

/// The [HomeRoute] is the entry point for the Contact Abyss app. It acts as the main menu for the game, presenting
/// options to the user to start a new game or load a saved game.
class HomeRoute extends StatefulWidget {
  /// Creates a new instance of [HomeRoute].
  const HomeRoute({super.key});

  @override
  HomeController createState() => HomeController();
}

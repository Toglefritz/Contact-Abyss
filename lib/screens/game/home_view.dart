import 'package:contact_abyss/screens/game/home_controller.dart';
import 'package:contact_abyss/screens/game/home_route.dart';
import 'package:contact_abyss/values/insets.dart';
import 'package:flutter/material.dart';

/// A view for the [GameRoute].
class GameView extends StatelessWidget {
  /// A controller for this view.
  final GameController state;

  /// Creates an instance of [GameView].
  const GameView(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String choice) {
              switch (choice) {
                case 'Reset':
                  state.resetGame(); // Call the resetGame method
                  break;
                case 'Return to Main Menu':
                  state.returnToMainMenu(); // Call the returnToMainMenu method
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Reset', 'Return to Main Menu'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Show the image for the game node if one is provided.
          Positioned(
            bottom: 0,
            child: Image.asset(
              'assets/images/cover.png',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
            ),
          ),

          // A translucent container to overlay the background image and provide contrast for the text.
          Container(
            color: Colors.black.withOpacity(0.7),
            width: double.infinity,
            height: double.infinity,
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Text
                Padding(
                  padding: const EdgeInsets.only(left: Insets.medium, right: Insets.medium, bottom: Insets.medium),
                  child: Text(
                    state.gameNode.storyText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                // Choices
                ...List.generate(state.gameNode.choices.length, (index) {
                  final choice = state.gameNode.choices[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Insets.large,
                    ),
                    child: TextButton(
                      onPressed: () => state.makeChoice(index),
                      child: Text(
                        '${index + 1}> ${choice.choiceText}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

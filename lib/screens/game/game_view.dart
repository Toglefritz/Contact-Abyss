import 'package:contact_abyss/screens/game/game_controller.dart';
import 'package:contact_abyss/screens/game/game_route.dart';
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
        leadingWidth: MediaQuery.of(context).size.width * 0.8,
        leading: Padding(
          padding: const EdgeInsets.only(left: Insets.medium),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: Insets.xSmall),
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    state.batteryIcon,
                    size: 36,
                  ),
                ),
              ), // Show the battery icon
              Text(
                '${state.batteryLevel}%',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String choice) {
              switch (choice) {
                case 'Reset':
                  state.resetGame(); // Call the resetGame method
                case 'Return to Main Menu':
                  state.returnToMainMenu(); // Call the returnToMainMenu method
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

          // The content of the game node.
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                // If the game has ended, show the outcome.
                if (state.gameNode.isEnd)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Insets.medium,
                      vertical: Insets.large,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          // Show an image based on the outcome.
                          Image.asset(
                            state.getOutcomeImage(),
                            width: MediaQuery.of(context).size.width * 0.6,
                          ),

                          // Display the outcome text.
                          Padding(
                            padding: const EdgeInsets.only(top: Insets.medium),
                            child: Text(
                              state.getOutcomeText(),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

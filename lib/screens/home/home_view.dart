import 'package:contact_abyss/screens/home/home_controller.dart';
import 'package:contact_abyss/screens/home/home_route.dart';
import 'package:flutter/material.dart';

import '../../values/insets.dart';

/// A view for the [HomeRoute].
class HomeView extends StatelessWidget {
  /// A controller for this view.
  final HomeController state;

  /// Creates an instance of [HomeView].
  const HomeView(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/cover.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // A translucent container to overlay the background image and provide contrast for the text.
          Container(
            color: Colors.black.withOpacity(0.5),
            width: double.infinity,
            height: double.infinity,
          ),

          AnimatedSwitcher(
            duration: const Duration(seconds: 2),
            child: state.gameDataService.isGameLoaded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title

                      Padding(
                        padding: const EdgeInsets.only(top: Insets.xxxLarge),
                        child: Text(
                          'Contact\nAbyss',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            shadows: [
                              const Shadow(
                                color: Colors.white,
                                blurRadius: 25,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Start button
                      Padding(
                        padding: const EdgeInsets.only(
                          top: Insets.xLarge,
                          left: Insets.large,
                          right: Insets.large,
                        ),
                        child: OutlinedButton(
                          onPressed: state.onNewGame,
                          child: Text(
                            'New Game',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

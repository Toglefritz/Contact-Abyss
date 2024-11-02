import 'package:contact_abyss/screens/home/home_controller.dart';
import 'package:contact_abyss/screens/home/home_route.dart';
import 'package:flutter/material.dart';

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
            color: Colors.black.withOpacity(0.3),
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );
  }
}

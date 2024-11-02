import 'package:contact_abyss/screens/home/home_route.dart';
import 'package:contact_abyss/theme/contact_abyss_theme.dart';
import 'package:flutter/material.dart';

/// The [ContactAbyssApp] is the root widget for the Contact Abyss game. It includes the [MaterialApp] widget that
/// acts as the root of the widget tree and provides navigation and theming for the app.
class ContactAbyssApp extends StatelessWidget {
  /// Creates a new instance of [HomeRoute].
  const ContactAbyssApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Abyss',
      debugShowCheckedModeBanner: false,
      theme: contactAbyssTheme,
      themeMode: ThemeMode.dark,
      home: const HomeRoute(),
    );
  }
}

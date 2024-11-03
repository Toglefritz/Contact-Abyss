import 'package:flutter/material.dart';

import '../values/insets.dart';

/// A [ThemeData] class that defines the visual properties of the Contact Abyss theme.
ThemeData contactAbyssTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Colors.black,
  ),
  fontFamily: 'KodeMono',
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 72,
      fontFamily: 'Autiowide',
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: 'Autiowide',
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.all(
          Insets.xSmall,
        ),
      ),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Insets.small),
        ),
      ),
    ),
  ),
);

// lib/utils/theme.dart
import 'package:flutter/material.dart';
import 'constants.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: kBackgroundColor,
  primaryColor: kPrimaryColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: kBackgroundColor,
    elevation: 1,
    iconTheme: IconThemeData(color: kPrimaryColor),
    titleTextStyle: TextStyle(
      color: kPrimaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kPrimaryColor,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kTextDark),
    bodyMedium: TextStyle(color: kTextDark),
    bodySmall: TextStyle(color: kTextDark),
    titleLarge: TextStyle(color: kPrimaryColor),
    titleMedium: TextStyle(color: kPrimaryColor),
    titleSmall: TextStyle(color: kPrimaryColor),
  ),
  colorScheme: ColorScheme.light(
    primary: kPrimaryColor,
    secondary: Colors.white,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: kPrimaryColor,
    onSurface: kPrimaryColor,
    error: Colors.red,
    onError: Colors.white,
  ),
);

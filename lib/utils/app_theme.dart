import 'package:flutter/material.dart';

/// Centralized app theme for colors, text styles, and spacing.
class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF667eea);
  static const Color accentColor = Color(0xFF43cea2);
  static const Color errorColor = Color(0xFFe57373);
  static const Color backgroundColor = Color(0xFFF5F6FA);
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Text Styles
  static const TextStyle headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.white,
  );

  // Spacing
  static const double padding = 20.0; 
  static const double cardRadius = 16.0;
  static const double buttonRadius = 20.0;
  static const double iconSize = 28.0;
}

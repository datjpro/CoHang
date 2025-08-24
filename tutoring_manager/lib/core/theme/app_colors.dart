import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1976D2),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD1E4FF),
    onPrimaryContainer: Color(0xFF001D35),
    secondary: Color(0xFF535F70),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD7E3F8),
    onSecondaryContainer: Color(0xFF101C2B),
    tertiary: Color(0xFF6B5778),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFF2DAFF),
    onTertiaryContainer: Color(0xFF251432),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    outline: Color(0xFF73777F),
    background: Color(0xFFFEFBFF),
    onBackground: Color(0xFF1B1B1F),
    surface: Color(0xFFFEFBFF),
    onSurface: Color(0xFF1B1B1F),
    surfaceVariant: Color(0xFFE1E2EC),
    onSurfaceVariant: Color(0xFF44474F),
    inverseSurface: Color(0xFF2F3033),
    onInverseSurface: Color(0xFFF1F0F4),
    inversePrimary: Color(0xFF9FCAFF),
    shadow: Color(0xFF000000),
    surfaceTint: Color(0xFF1976D2),
    outlineVariant: Color(0xFFC4C6D0),
    scrim: Color(0xFF000000),
  );

  // Dark Theme Colors
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF9FCAFF),
    onPrimary: Color(0xFF003257),
    primaryContainer: Color(0xFF00497D),
    onPrimaryContainer: Color(0xFFD1E4FF),
    secondary: Color(0xFFBBC7DB),
    onSecondary: Color(0xFF253140),
    secondaryContainer: Color(0xFF3B4858),
    onSecondaryContainer: Color(0xFFD7E3F8),
    tertiary: Color(0xFFD6BEE4),
    onTertiary: Color(0xFF3B2948),
    tertiaryContainer: Color(0xFF523F5F),
    onTertiaryContainer: Color(0xFFF2DAFF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    outline: Color(0xFF8D9199),
    background: Color(0xFF111318),
    onBackground: Color(0xFFE2E2E9),
    surface: Color(0xFF111318),
    onSurface: Color(0xFFE2E2E9),
    surfaceVariant: Color(0xFF44474F),
    onSurfaceVariant: Color(0xFFC4C6D0),
    inverseSurface: Color(0xFFE2E2E9),
    onInverseSurface: Color(0xFF2F3033),
    inversePrimary: Color(0xFF1976D2),
    shadow: Color(0xFF000000),
    surfaceTint: Color(0xFF9FCAFF),
    outlineVariant: Color(0xFF44474F),
    scrim: Color(0xFF000000),
  );

  // Additional semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Subject colors
  static const Map<String, Color> subjectColors = {
    'math': Color(0xFF2196F3),
    'physics': Color(0xFF9C27B0),
    'chemistry': Color(0xFF4CAF50),
    'biology': Color(0xFFFF9800),
    'english': Color(0xFFF44336),
    'literature': Color(0xFF795548),
  };

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF1976D2),
    Color(0xFF1565C0),
  ];

  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF388E3C),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFF9800),
    Color(0xFFF57C00),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFF44336),
    Color(0xFFD32F2F),
  ];
}

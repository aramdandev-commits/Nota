import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  // ─────────────────────────────────────────────────
  // Brand / Accent Colors  (shared by both themes)
  // ─────────────────────────────────────────────────
  static const Color brandPink = Color(0xFFE520A4);
  static const Color brandPurple = Color(0xFF7A36DC);
  static const Color brandBlue = Color(0xFF1D84FF);

  // ─────────────────────────────────────────────────
  // Dark Theme raw palette
  // ─────────────────────────────────────────────────
  static const Color darkScaffold = Color(0xFF0F111A);
  static const Color darkCard = Color(0xFF1E1E24);
  static const Color darkSurface = Color(0xFF1E1E2A); // used in bottom sheets
  static const Color darkItem = Color(0xFF2A2A38); // inner cards / items

  // ─────────────────────────────────────────────────
  // Light Theme raw palette
  // ─────────────────────────────────────────────────
  static const Color lightScaffold = Color(0xFFF9F9F9);
  static const Color lightCard = Colors.white;
  static const Color lightSurface = Colors.white; // bottom sheets
  static const Color lightItem = Color(0xFFF0F0F5); // inner cards / items

  // ─────────────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightScaffold,
    canvasColor: lightScaffold,
    cardColor: lightCard,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      primary: brandPurple,
      secondary: brandPink,
      surface: lightCard,
      onSurface: Color(0xFF1E1E24), // dark text on light bg
      onPrimary: Colors.white,
      outline: Color(0xFFE0E0E0),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1E1E24), fontFamily: 'Inter'),
      bodyMedium: TextStyle(color: Color(0xFF5A5A72), fontFamily: 'Inter'),
      bodySmall: TextStyle(color: Color(0xFF8E8EA8), fontFamily: 'Inter'),
      titleLarge: TextStyle(
          color: Color(0xFF1E1E24),
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold),
      titleMedium: TextStyle(
          color: Color(0xFF1E1E24),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF1E1E24)),
    dividerColor: Color(0xFFE0E0E0),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // ─────────────────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkScaffold,
    canvasColor: darkScaffold,
    cardColor: darkCard,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    colorScheme: const ColorScheme.dark(
      primary: brandPurple,
      secondary: brandPink,
      surface: darkCard,
      onSurface: Colors.white, // light text on dark bg
      onPrimary: Colors.white,
      outline: Color(0xFF2A2A38),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Inter'),
      bodyMedium: TextStyle(color: Color(0xFF8E9099), fontFamily: 'Inter'),
      bodySmall: TextStyle(color: Color(0xFF5A5A72), fontFamily: 'Inter'),
      titleLarge: TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold),
      titleMedium: TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    dividerColor: Color(0xFF2A2A38),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // ─────────────────────────────────────────────────
  // Helpers — use these in widgets instead of raw Color constants
  // ─────────────────────────────────────────────────

  /// Returns the surface color for bottom sheets / modals.
  static Color sheetColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSurface
          : lightSurface;

  /// Returns the item/inner-card color (nested containers inside sheets).
  static Color itemColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkItem : lightItem;
}

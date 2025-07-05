import 'package:flutter/material.dart';

class AppTheme {
  // Warna utama aplikasi
  static const Color primaryColor = Color(0xFF1C355F);
  static const Color secondaryColor = Color(0xFF625B71);
  static const Color tertiaryColor = Color(0xFF7D5260);
  static const Color errorColor = Color(0xFFBA1A1A);

  // Warna untuk light theme
  static const Color lightSurface = Color(0xFFF2F2F2);
  static const Color lightBackground = Color(0xFFFFFBFE);
  static const Color lightOnSurface = Color(0xFF1C1B1F);

  // Warna untuk dark theme
  static const Color darkSurface = Color(0xFF1C1B1F);
  static const Color darkBackground = Color(0xFF1C1B1F);
  static const Color darkOnSurface = Color(0xFFE6E1E5);

  // Light Theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.light,
          ).copyWith(
            primary: primaryColor,
            secondary: secondaryColor,
            tertiary: tertiaryColor,
            surface: lightSurface,
            error: errorColor,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: lightOnSurface,
            onError: Colors.white,
          ),
      appBarTheme: _appBarTheme(true),
      elevatedButtonTheme: _elevatedButtonTheme(true),
      cardTheme: _cardTheme(),
      inputDecorationTheme: _inputDecorationTheme(true),
      textTheme: _textTheme(true),
    );
  }

  // Dark Theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.dark,
          ).copyWith(
            primary: const Color(0xFFD0BCFF),
            secondary: const Color(0xFFCCC2DC),
            tertiary: const Color(0xFFEFB8C8),
            surface: darkSurface,
            error: const Color(0xFFFFB4AB),
            onPrimary: const Color(0xFF381E72),
            onSecondary: const Color(0xFF332D41),
            onSurface: darkOnSurface,
            onError: const Color(0xFF690005),
          ),
      appBarTheme: _appBarTheme(false),
      elevatedButtonTheme: _elevatedButtonTheme(false),
      cardTheme: _cardTheme(),
      inputDecorationTheme: _inputDecorationTheme(false),
      textTheme: _textTheme(false),
    );
  }

  // AppBar Theme
  static AppBarTheme _appBarTheme(bool isLight) {
    return AppBarTheme(
      backgroundColor: isLight ? primaryColor : darkSurface,
      foregroundColor: isLight ? Colors.white : darkOnSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isLight ? Colors.white : darkOnSurface,
      ),
    );
  }

  // ElevatedButton Theme
  static ElevatedButtonThemeData _elevatedButtonTheme(bool isLight) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isLight ? primaryColor : const Color(0xFFD0BCFF),
        foregroundColor: isLight ? Colors.white : const Color(0xFF381E72),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Card Theme
  static CardThemeData _cardTheme() {
    return CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  // Input Decoration Theme
  static InputDecorationTheme _inputDecorationTheme(bool isLight) {
    return InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isLight ? primaryColor : const Color(0xFFD0BCFF),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isLight ? Colors.grey.shade400 : Colors.grey.shade600,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Text Theme
  static TextTheme _textTheme(bool isLight) {
    final baseColor = isLight ? lightOnSurface : darkOnSurface;

    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
    );
  }
}

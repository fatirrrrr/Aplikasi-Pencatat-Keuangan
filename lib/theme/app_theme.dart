import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kelas ini mendefinisikan seluruh tema untuk aplikasi,
/// termasuk skema warna dan styling untuk mode terang (light) dan gelap (dark).
/// Menggunakan pendekatan terpusat ini memastikan konsistensi visual
/// dan mempermudah pemeliharaan desain.
class AppTheme {
  // --- WARNA UTAMA (BRAND COLORS) ---
  // Warna ini menjadi dasar untuk 'seed' dari ColorScheme di Material 3.
  static const Color primaryColor = Color(0xFF1C355F); // Biru Tua Korporat
  static const Color secondaryColor = Color(
    0xFF625B71,
  ); // Warna sekunder netral
  static const Color tertiaryColor = Color(0xFF7D5260); // Warna tersier netral
  static const Color errorColor = Color(
    0xFFBA1A1A,
  ); // Warna standar untuk error

  // --- WARNA SPESIFIK UNTUK LIGHT THEME ---
  static const Color lightSurface = Color(
    0xFFF2F2F2,
  ); // Warna permukaan/latar belakang kartu (sedikit abu-abu)
  static const Color lightBackground = Color(
    0xFFFFFBFE,
  ); // Warna latar belakang utama (putih kebiruan)
  static const Color lightOnSurface = Color(
    0xFF1C1B1F,
  ); // Warna teks di atas surface (hitam pekat)

  // --- WARNA SPESIFIK UNTUK DARK THEME ---
  static const Color darkSurface = Color(
    0xFF1C1B1F,
  ); // Warna permukaan/latar belakang kartu (abu-abu gelap)
  static const Color darkBackground = Color(
    0xFF1C1B1F,
  ); // Warna latar belakang utama (abu-abu gelap)
  static const Color darkOnSurface = Color(
    0xFFE6E1E5,
  ); // Warna teks di atas surface (putih keabu-abuan)

  // =================================================================
  //                       TEMA TERANG (LIGHT THEME)
  // =================================================================
  static ThemeData lightTheme() {
    final colorScheme =
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
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      appBarTheme: _appBarTheme(isLight: true, scheme: colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(
        isLight: true,
        scheme: colorScheme,
      ),
      cardTheme: _cardTheme(),
      inputDecorationTheme: _inputDecorationTheme(
        isLight: true,
        scheme: colorScheme,
      ),
      textTheme: _textTheme(baseColor: lightOnSurface),
    );
  }

  // =================================================================
  //                        TEMA GELAP (DARK THEME)
  // =================================================================
  static ThemeData darkTheme() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(
            0xFFB3C5FF,
          ), // Primary versi terang untuk dark mode
          secondary: const Color(0xFFCCC2DC),
          tertiary: const Color(0xFFEFB8C8),
          surface: darkSurface,
          error: const Color(0xFFFFB4AB),
          onPrimary: const Color(0xFF002B75),
          onSecondary: const Color(0xFF332D41),
          onSurface: darkOnSurface,
          onError: const Color(0xFF690005),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      appBarTheme: _appBarTheme(isLight: false, scheme: colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(
        isLight: false,
        scheme: colorScheme,
      ),
      cardTheme: _cardTheme(),
      inputDecorationTheme: _inputDecorationTheme(
        isLight: false,
        scheme: colorScheme,
      ),
      textTheme: _textTheme(
        baseColor: lightOnSurface,
      ).apply(bodyColor: darkOnSurface, displayColor: darkOnSurface),
    );
  }

  // =================================================================
  //                KUSTOMISASI KOMPONEN (WIDGETS)
  // =================================================================

  static AppBarTheme _appBarTheme({
    required bool isLight,
    required ColorScheme scheme,
  }) {
    return AppBarTheme(
      backgroundColor: isLight ? scheme.primary : scheme.surface,
      foregroundColor: isLight ? scheme.onPrimary : scheme.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isLight ? scheme.onPrimary : scheme.onSurface,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme({
    required bool isLight,
    required ColorScheme scheme,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
      ),
    );
  }

  static CardThemeData _cardTheme() {
    return CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      clipBehavior: Clip.antiAlias, // Mencegah konten keluar dari sudut rounded
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required bool isLight,
    required ColorScheme scheme,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // Tidak ada border saat normal
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: scheme.onSurface.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    );
  }

  static TextTheme _textTheme({required Color baseColor}) {
    final fontFamily = GoogleFonts.poppins().fontFamily;

    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseColor,
        fontFamily: fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseColor,
        fontFamily: fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseColor,
        fontFamily: fontFamily,
      ),

      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
        fontFamily: fontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
        fontFamily: fontFamily,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
        fontFamily: fontFamily,
      ),

      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
        fontFamily: fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
        fontFamily: fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: baseColor,
        fontFamily: fontFamily,
      ),

      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
        fontFamily: fontFamily,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseColor,
        fontFamily: fontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: baseColor,
        fontFamily: fontFamily,
      ),
    );
  }
}

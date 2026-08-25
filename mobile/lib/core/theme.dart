import 'package:flutter/material.dart';

import 'colors.dart';

/// SHARED — frozen after Phase 0. Announce before changing.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      error: AppColors.danger,
      surface: isDark ? AppColors.surfaceDark : Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.surfaceDark : AppColors.surfaceLight,

      // Sinhala and Tamil are NOT covered by Roboto. Leaving fontFamily null
      // makes Flutter fall through to the platform font stack, where Android
      // resolves Noto Sans Sinhala / Noto Sans Tamil. Setting an explicit
      // Latin-only family here (or bundling one via google_fonts) would render
      // tofu boxes for two of our three languages — the single easiest way to
      // break this app. If you ever need a custom font, you must bundle all
      // three scripts.
      fontFamily: null,

      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        foregroundColor:
            isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isDark ? const Color(0xFF141414) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // globals.css enforces a 44px minimum tap target on mobile; match it.
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF141414) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB),
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(
          color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        strokeCap: StrokeCap.round,
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

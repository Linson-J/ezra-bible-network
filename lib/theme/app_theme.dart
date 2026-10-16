import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF0E0B2A); // deep indigo
  static const surface = Color(0xFF1A1645);
  static const surfaceHigh = Color(0xFF252062);
  static const primary = Color(0xFF6C4FE0); // royal purple
  static const deepBlue = Color(0xFF22307A);
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF1D78A);
  static const text = Color(0xFFEDEBFA);
  static const textMuted = Color(0xFFA9A5CC);
  static const live = Color(0xFFE53935);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepBlue, Color(0xFF3A2490)],
  );
}

class AppTheme {
  AppTheme._();

  /// Serif face for Scripture (Noto Serif on Android).
  static const verseFont = 'serif';

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.gold,
      onSecondary: Color(0xFF231A00),
      tertiary: AppColors.deepBlue,
      onTertiary: Colors.white,
      error: Color(0xFFFF6B6B),
      onError: Colors.black,
      surface: AppColors.background,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.textMuted,
      surfaceContainerLowest: Color(0xFF0A0820),
      surfaceContainerLow: Color(0xFF141038),
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surfaceHigh,
      surfaceContainerHighest: Color(0xFF2F2A73),
      outline: Color(0xFF4A4590),
      outlineVariant: Color(0xFF2E2A66),
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.text),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.gold.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              color: s.contains(WidgetState.selected) ? AppColors.gold : AppColors.textMuted,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
              fontSize: 12,
              fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
              color: s.contains(WidgetState.selected) ? AppColors.gold : AppColors.textMuted,
            )),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.gold,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.gold,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: Color(0xFF4A4590)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.gold : null),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.gold.withValues(alpha: 0.35) : null),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: TextStyle(color: AppColors.text),
      ),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.gold),
      dividerTheme: const DividerThemeData(color: Color(0xFF2E2A66), space: 1),
    );
  }
}

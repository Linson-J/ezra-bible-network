import 'package:flutter/material.dart';

/// Brand colours for surfaces that stay dark in both themes: the video area,
/// the splash screen and the config error screen. Everything else should use
/// [AppPalette] via `context.palette`.
class AppColors {
  AppColors._();

  static const background = Color(0xFF0E0B2A); // deep indigo
  static const primary = Color(0xFF6C4FE0); // royal purple
  static const deepBlue = Color(0xFF22307A);
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF1D78A);
  static const onGold = Color(0xFF231A00);
  static const textMuted = Color(0xFFA9A5CC);
  static const live = Color(0xFFE53935);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepBlue, Color(0xFF3A2490)],
  );
}

/// Theme-dependent colours. Read with `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.primary,
    required this.gold,
    required this.goldLight,
    required this.goldFill,
    required this.onGold,
    required this.text,
    required this.textMuted,
    required this.live,
    required this.outline,
    required this.outlineVariant,
    required this.headerGradient,
    required this.verseGradient,
  });

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color primary;

  /// Gold for icons, labels and accents on [background]/[surface].
  final Color gold;

  /// Softer gold for secondary text (speakers, verse references).
  final Color goldLight;

  /// Fill for gold buttons, with [onGold] on top.
  final Color goldFill;
  final Color onGold;

  final Color text;
  final Color textMuted;
  final Color live;
  final Color outline;
  final Color outlineVariant;

  /// Hero cards (More header, programme thumbnails). Text on it uses [text].
  final LinearGradient headerGradient;
  final LinearGradient verseGradient;

  static const dark = AppPalette(
    background: AppColors.background,
    surface: Color(0xFF1A1645),
    surfaceHigh: Color(0xFF252062),
    primary: AppColors.primary,
    gold: AppColors.gold,
    goldLight: AppColors.goldLight,
    goldFill: AppColors.gold,
    onGold: AppColors.onGold,
    text: Color(0xFFEDEBFA),
    textMuted: AppColors.textMuted,
    live: AppColors.live,
    outline: Color(0xFF4A4590),
    outlineVariant: Color(0xFF2E2A66),
    headerGradient: AppColors.brandGradient,
    verseGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2B1F78), Color(0xFF16124A)],
    ),
  );

  // Same hues as dark, with the gold darkened so text and icons stay
  // readable (>= 4.5:1) on white.
  static const light = AppPalette(
    background: Color(0xFFF6F4FB),
    surface: Colors.white,
    surfaceHigh: Color(0xFFECE8FA),
    primary: Color(0xFF5B3FD0),
    gold: Color(0xFF8A6A0B),
    goldLight: Color(0xFF93721A),
    goldFill: AppColors.gold,
    onGold: AppColors.onGold,
    text: Color(0xFF1C1840),
    textMuted: Color(0xFF5F5A82),
    live: Color(0xFFD32F2F),
    outline: Color(0xFFC9C3E4),
    outlineVariant: Color(0xFFE3DFF2),
    headerGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE3DEFF), Color(0xFFF3EAFF)],
    ),
    verseGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFFBF0), Color(0xFFEEE9FF)],
    ),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceHigh: c(surfaceHigh, other.surfaceHigh),
      primary: c(primary, other.primary),
      gold: c(gold, other.gold),
      goldLight: c(goldLight, other.goldLight),
      goldFill: c(goldFill, other.goldFill),
      onGold: c(onGold, other.onGold),
      text: c(text, other.text),
      textMuted: c(textMuted, other.textMuted),
      live: c(live, other.live),
      outline: c(outline, other.outline),
      outlineVariant: c(outlineVariant, other.outlineVariant),
      headerGradient: LinearGradient.lerp(headerGradient, other.headerGradient, t)!,
      verseGradient: LinearGradient.lerp(verseGradient, other.verseGradient, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.dark;
}

class AppTheme {
  AppTheme._();

  /// Serif face for Scripture (Noto Serif on Android).
  static const verseFont = 'serif';

  static ThemeData get dark => _build(
        AppPalette.dark,
        const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.gold,
          onSecondary: AppColors.onGold,
          tertiary: AppColors.deepBlue,
          onTertiary: Colors.white,
          error: Color(0xFFFF6B6B),
          onError: Colors.black,
          surface: AppColors.background,
          onSurface: Color(0xFFEDEBFA),
          onSurfaceVariant: AppColors.textMuted,
          surfaceContainerLowest: Color(0xFF0A0820),
          surfaceContainerLow: Color(0xFF141038),
          surfaceContainer: Color(0xFF1A1645),
          surfaceContainerHigh: Color(0xFF252062),
          surfaceContainerHighest: Color(0xFF2F2A73),
          outline: Color(0xFF4A4590),
          outlineVariant: Color(0xFF2E2A66),
        ),
      );

  static ThemeData get light => _build(
        AppPalette.light,
        const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF5B3FD0),
          onPrimary: Colors.white,
          secondary: Color(0xFF8A6A0B),
          onSecondary: Colors.white,
          tertiary: AppColors.deepBlue,
          onTertiary: Colors.white,
          error: Color(0xFFC62828),
          onError: Colors.white,
          surface: Color(0xFFF6F4FB),
          onSurface: Color(0xFF1C1840),
          onSurfaceVariant: Color(0xFF5F5A82),
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: Color(0xFFFBFAFE),
          surfaceContainer: Colors.white,
          surfaceContainerHigh: Color(0xFFECE8FA),
          surfaceContainerHighest: Color(0xFFE3DEF7),
          outline: Color(0xFFC9C3E4),
          outlineVariant: Color(0xFFE3DFF2),
        ),
      );

  static ThemeData _build(AppPalette p, ColorScheme scheme) {
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    return base.copyWith(
      extensions: [p],
      scaffoldBackgroundColor: p.background,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: p.text),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.goldFill.withValues(alpha: scheme.brightness == Brightness.dark ? 0.18 : 0.28),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              color: s.contains(WidgetState.selected) ? p.gold : p.textMuted,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
              fontSize: 12,
              fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
              color: s.contains(WidgetState.selected) ? p.gold : p.textMuted,
            )),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          // Light cards sit on a near-white background and need an edge.
          side: scheme.brightness == Brightness.light
              ? BorderSide(color: p.outlineVariant)
              : BorderSide.none,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.gold,
        unselectedLabelColor: p.textMuted,
        indicatorColor: p.gold,
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
          foregroundColor: p.text,
          side: BorderSide(color: p.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: p.goldFill.withValues(alpha: 0.22),
          selectedForegroundColor: p.gold,
          foregroundColor: p.textMuted,
          side: BorderSide(color: p.outline),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.goldFill : null),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? p.goldFill.withValues(alpha: 0.35) : null),
        trackOutlineColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? p.gold.withValues(alpha: 0.6) : null),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: scheme.brightness == Brightness.light
              ? BorderSide(color: p.outline)
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: scheme.brightness == Brightness.light
              ? BorderSide(color: p.outline)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.gold),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.brightness == Brightness.dark ? p.surfaceHigh : p.text,
        contentTextStyle: TextStyle(color: scheme.brightness == Brightness.dark ? p.text : Colors.white),
      ),
      listTileTheme: ListTileThemeData(iconColor: p.gold),
      dividerTheme: DividerThemeData(color: p.outlineVariant, space: 1),
    );
  }
}

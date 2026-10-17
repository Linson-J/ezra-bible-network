import 'package:flutter/material.dart';

/// Brand colours for surfaces that stay dark in both themes: the video area,
/// the splash screen and the config error screen. Everything else should use
/// [AppPalette] via `context.palette`.
class AppColors {
  AppColors._();

  static const background = Color(0xFF000000); // splash
  static const primary = Color(0xFF6C4FE0);
  static const deepBlue = Color(0xFF22307A);

  /// Light blue: buttons, switches and highlights, with black on top.
  static const accent = Color(0xFF7CCFF5);
  static const accentLight = Color(0xFFB9E6FB);
  static const onAccent = Color(0xFF000000);
  static const textMuted = Color(0xFFA3A3A0);
  static const live = Color(0xFFE03C3C);
  static const video = Color(0xFF000000);

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
    required this.accent,
    required this.accentFill,
    required this.onAccent,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.live,
    required this.outline,
    required this.outlineVariant,
    required this.tiles,
  });

  final Color background;
  final Color surface;

  /// Placeholder photo areas and progress-bar tracks.
  final Color surfaceHigh;

  /// Blue for icons and links; dark enough to read on [background].
  final Color accent;

  /// Fill for accent buttons and switches, with [onAccent] on top.
  final Color accentFill;
  final Color onAccent;

  final Color text;
  final Color textMuted;

  /// Programmes that have already aired.
  final Color textFaint;
  final Color live;

  /// Outlined buttons.
  final Color outline;

  /// Dividers.
  final Color outlineVariant;

  /// Pale blues for thumbnails and icon chips; cycled by index.
  final List<Color> tiles;

  Color tile(int i) => tiles[i % tiles.length];

  static const light = AppPalette(
    background: Colors.white,
    surface: Colors.white,
    surfaceHigh: Color(0xFFE3EEF5),
    accent: Color(0xFF0277BD),
    accentFill: AppColors.accent,
    onAccent: AppColors.onAccent,
    text: Color(0xFF000000),
    textMuted: Color(0xFF5F6B73),
    textFaint: Color(0xFF9E9E9E),
    live: Color(0xFFD93636),
    outline: Color(0xFFD3DEE5),
    outlineVariant: Color(0xFFE5EDF2),
    tiles: [Color(0xFFE3F3FC), Color(0xFFEAF4FA), Color(0xFFEEF3F6)],
  );

  static const dark = AppPalette(
    background: Color(0xFF000000),
    surface: Color(0xFF0E1418),
    surfaceHigh: Color(0xFF1A242B),
    accent: Color(0xFF7CCFF5),
    accentFill: AppColors.accent,
    onAccent: AppColors.onAccent,
    text: Color(0xFFFFFFFF),
    textMuted: Color(0xFF9FB0BA),
    textFaint: Color(0xFF63727C),
    live: Color(0xFFEF5350),
    outline: Color(0xFF2C3A43),
    outlineVariant: Color(0xFF1C262D),
    tiles: [Color(0xFF12222C), Color(0xFF152630), Color(0xFF172128)],
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
      accent: c(accent, other.accent),
      accentFill: c(accentFill, other.accentFill),
      onAccent: c(onAccent, other.onAccent),
      text: c(text, other.text),
      textMuted: c(textMuted, other.textMuted),
      textFaint: c(textFaint, other.textFaint),
      live: c(live, other.live),
      outline: c(outline, other.outline),
      outlineVariant: c(outlineVariant, other.outlineVariant),
      tiles: [for (var i = 0; i < tiles.length; i++) c(tiles[i], other.tile(i))],
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

/// Type styles from the design: condensed display headlines, letter-spaced
/// eyebrows and a serif for Scripture.
class AppText {
  AppText._();

  static const bodyFont = 'Archivo';
  static const displayFont = 'ArchivoCondensed';
  static const verseFont = 'EBGaramond';

  /// "SUNDAY WORSHIP". Callers upper-case the text.
  static TextStyle display(double size, {Color? color}) => TextStyle(
    fontFamily: displayFont,
    fontWeight: FontWeight.w800,
    fontSize: size,
    height: 0.95,
    letterSpacing: -0.2,
    color: color,
  );

  /// "LATER TODAY", "LIVE NOW". Callers upper-case the text.
  static TextStyle eyebrow(Color color, {double size = 13}) =>
      TextStyle(fontSize: size, fontWeight: FontWeight.w700, letterSpacing: size * 0.16, color: color);
}

class AppTheme {
  AppTheme._();

  static const verseFont = AppText.verseFont;

  static ThemeData get light => _build(
    AppPalette.light,
    const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF0277BD),
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: AppColors.onAccent,
      error: Color(0xFFC62828),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF000000),
      onSurfaceVariant: Color(0xFF5F6B73),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFF8FBFD),
      surfaceContainer: Color(0xFFF2F7FA),
      surfaceContainerHigh: Color(0xFFEAF2F7),
      surfaceContainerHighest: Color(0xFFE3EEF5),
      outline: Color(0xFFD3DEE5),
      outlineVariant: Color(0xFFE5EDF2),
    ),
  );

  static ThemeData get dark => _build(
    AppPalette.dark,
    const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.accent,
      onSecondary: AppColors.onAccent,
      error: Color(0xFFFF6B6B),
      onError: Colors.black,
      surface: Color(0xFF000000),
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFF9FB0BA),
      surfaceContainerLowest: Color(0xFF000000),
      surfaceContainerLow: Color(0xFF0A1014),
      surfaceContainer: Color(0xFF0E1418),
      surfaceContainerHigh: Color(0xFF141D23),
      surfaceContainerHighest: Color(0xFF1A242B),
      outline: Color(0xFF2C3A43),
      outlineVariant: Color(0xFF1C262D),
    ),
  );

  static ThemeData _build(AppPalette p, ColorScheme scheme) {
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: AppText.bodyFont);
    return base.copyWith(
      extensions: [p],
      scaffoldBackgroundColor: p.background,
      // iOS: no ripples; rows and buttons highlight softly while pressed.
      splashFactory: NoSplash.splashFactory,
      highlightColor: p.text.withValues(alpha: 0.06),
      hoverColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.display(26, color: p.text),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.outlineVariant),
        ),
      ),
      // iOS capsule buttons: filled (light blue) and tinted grey.
      filledButtonTheme: FilledButtonThemeData(
        style: _iosButton(
          FilledButton.styleFrom(
            backgroundColor: p.accentFill,
            foregroundColor: p.onAccent,
            disabledBackgroundColor: p.text.withValues(alpha: 0.08),
            disabledForegroundColor: p.text.withValues(alpha: 0.3),
          ),
          pressed: Colors.white.withValues(alpha: 0.22),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _iosButton(
          OutlinedButton.styleFrom(
            foregroundColor: p.text,
            backgroundColor: p.text.withValues(alpha: 0.07),
            side: BorderSide.none,
          ),
          pressed: p.text.withValues(alpha: 0.08),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          overlayColor: Colors.transparent,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontFamily: AppText.bodyFont, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(overlayColor: p.text, highlightColor: p.text.withValues(alpha: 0.08)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: p.accentFill.withValues(alpha: 0.22),
          selectedForegroundColor: p.text,
          foregroundColor: p.textMuted,
          side: BorderSide(color: p.outline),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : p.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.accentFill : p.outlineVariant,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.accentFill : p.outline,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
        backgroundColor: p.text,
        contentTextStyle: TextStyle(fontFamily: AppText.bodyFont, color: p.background),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.text,
        titleTextStyle: TextStyle(
          fontFamily: AppText.bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: p.text,
        ),
        subtitleTextStyle: TextStyle(fontFamily: AppText.bodyFont, fontSize: 14, color: p.textMuted),
      ),
      dividerTheme: DividerThemeData(color: p.outlineVariant, space: 1, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accentFill),
    );
  }

  /// Capsule shape, iOS type size, and a flat highlight instead of a ripple.
  static ButtonStyle _iosButton(ButtonStyle base, {required Color pressed}) => base.copyWith(
    shape: const WidgetStatePropertyAll(StadiumBorder()),
    minimumSize: const WidgetStatePropertyAll(Size(64, 50)),
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 22, vertical: 14)),
    elevation: const WidgetStatePropertyAll(0),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontFamily: AppText.bodyFont, fontSize: 17, fontWeight: FontWeight.w600),
    ),
    overlayColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.pressed) ? pressed : null),
  );
}

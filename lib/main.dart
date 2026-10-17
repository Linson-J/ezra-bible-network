import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/app_constants.dart';
import 'config/env.dart';
import 'repositories/repository_provider.dart';
import 'screens/splash_screen.dart';
import 'services/settings_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait everywhere; the player's fullscreen switches to landscape.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await Env.load();
  } on EnvException catch (e) {
    runApp(ConfigErrorApp(message: e.message));
    return;
  }

  final settings = await SettingsService.load();
  final appState = AppState(repos: Repositories.fromEnv(), settings: settings);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: appState),
      ],
      child: const EzraApp(),
    ),
  );
}

class EzraApp extends StatelessWidget {
  const EzraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<SettingsService, ThemeMode>(
      (s) => s.themeMode,
    );
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      scrollBehavior: const _IosScrollBehavior(),
      home: const SplashScreen(),
    );
  }
}

/// iPhone-style rubber-band scrolling everywhere, without the Android glow.
class _IosScrollBehavior extends MaterialScrollBehavior {
  const _IosScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

/// Shown instead of the app when .env is missing or invalid.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.live,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Configuration error',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  message,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

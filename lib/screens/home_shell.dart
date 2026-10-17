import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../services/native_bridge.dart';
import '../services/player_service.dart';
import '../services/settings_service.dart';
import '../state/app_state.dart';
import '../utils/launcher.dart';
import '../widgets/app_bottom_bar.dart';
import '../widgets/ios_press.dart';
import 'live_screen.dart';
import 'more_screen.dart';
import 'verse_screen.dart';

/// Bottom navigation: Live, Verse, More.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  late final AppState _app = context.read<AppState>();
  StreamSubscription<String>? _tapSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _app.player.start();
    _tapSub = _app.notifications.taps.listen(_openPayload);
    final launch = _app.notifications.takeLaunchPayload();
    if (launch != null) _openPayload(launch);
    WidgetsBinding.instance.addPostFrameCallback((_) => _firstRunPrompts());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tapSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _app.onResume();
  }

  void _openPayload(String payload) {
    if (payload == AppConstants.payloadVerse) _app.tab.value = 1;
    if (payload == AppConstants.payloadLive) _app.tab.value = 0;
  }

  /// Force-update check, then the Android 13+ notification permission, then a
  /// one-time battery-optimisation prompt.
  Future<void> _firstRunPrompts() async {
    if (_app.updateRequired) {
      await _showUpdateDialog();
      return;
    }
    final settings = context.read<SettingsService>();

    if (!settings.notificationPromptShown) {
      await settings.markNotificationPromptShown();
      if (!await _app.notifications.areEnabled()) {
        await _app.notifications.requestPermission();
      }
      await _app.rescheduleDailyVerses();
    }

    if (!settings.batteryPromptShown && mounted) {
      await settings.markBatteryPromptShown();
      if (await NativeBridge.instance.isIgnoringBatteryOptimizations()) return;
      if (!mounted) return;
      final open = await showIosAlert<bool>(
        context,
        title: 'Keep the stream playing',
        message:
            'Android\'s battery optimisation can stop the live stream in the background '
            'and delay your daily verse.\n\nOn the next screen, choose "All apps", find '
            'Ezra Bible Network and select "Don\'t optimise".',
        actions: [('Not now', false, false), ('Open settings', true, true)],
      );
      if (open == true) await NativeBridge.instance.openBatteryOptimizationSettings();
    }
  }

  // The Update action opens the store and leaves the alert up, so the app
  // stays blocked until it is updated.
  Future<void> _showUpdateDialog() => showCupertinoDialog<void>(
    context: context,
    builder: (ctx) => PopScope(
      canPop: false,
      child: CupertinoAlertDialog(
        title: const Text('Update required'),
        content: const Text(
          'A new version of Ezra Bible Network is available. '
          'Please update to continue.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Launcher.url(ctx, AppConstants.playStoreUrl),
            child: const Text('Update'),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PlayerService>.value(
      value: _app.player,
      child: ValueListenableBuilder<bool>(
        valueListenable: NativeBridge.instance.inPip,
        builder: (context, inPip, _) => ValueListenableBuilder<int>(
          valueListenable: _app.tab,
          builder: (context, tab, _) {
            // In PiP only the Live tab (which then shows just the video) is visible.
            final index = inPip ? 0 : tab;
            return Scaffold(
              extendBody: true,
              body: IndexedStack(index: index, children: const [LiveScreen(), VerseScreen(), MoreScreen()]),
              bottomNavigationBar: inPip ? null : AppBottomBar(index: index, onSelect: (i) => _app.tab.value = i),
            );
          },
        ),
      ),
    );
  }
}

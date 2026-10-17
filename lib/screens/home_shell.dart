import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../services/native_bridge.dart';
import '../services/player_service.dart';
import '../services/settings_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/launcher.dart';
import 'live_screen.dart';
import 'more_screen.dart';
import 'schedule_screen.dart';
import 'verse_screen.dart';

/// Bottom navigation: Live, Schedule, Verse, More.
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
    if (payload == AppConstants.payloadVerse) _app.tab.value = 2;
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
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: Icon(Icons.battery_saver_rounded, color: context.palette.gold),
          title: const Text('Keep the stream playing'),
          content: const Text(
            'Android\'s battery optimisation can stop the live stream in the background '
            'and delay your daily verse.\n\nOn the next screen, choose "All apps", find '
            'Ezra Bible Network and select "Don\'t optimise".',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not now')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Open settings')),
          ],
        ),
      );
      if (open == true) await NativeBridge.instance.openBatteryOptimizationSettings();
    }
  }

  Future<void> _showUpdateDialog() => showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Update required'),
            content: const Text('A new version of Ezra Bible Network is available. '
                'Please update to continue.'),
            actions: [
              FilledButton(
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
              body: IndexedStack(
                index: index,
                children: const [LiveScreen(), ScheduleScreen(), VerseScreen(), MoreScreen()],
              ),
              bottomNavigationBar: inPip
                  ? null
                  : NavigationBar(
                      selectedIndex: index,
                      onDestinationSelected: (i) => _app.tab.value = i,
                      destinations: const [
                        NavigationDestination(
                            icon: Icon(Icons.live_tv_outlined),
                            selectedIcon: Icon(Icons.live_tv_rounded),
                            label: 'Live'),
                        NavigationDestination(
                            icon: Icon(Icons.calendar_month_outlined),
                            selectedIcon: Icon(Icons.calendar_month_rounded),
                            label: 'Schedule'),
                        NavigationDestination(
                            icon: Icon(Icons.menu_book_outlined),
                            selectedIcon: Icon(Icons.menu_book_rounded),
                            label: 'Verse'),
                        NavigationDestination(
                            icon: Icon(Icons.more_horiz_rounded), label: 'More'),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/native_bridge.dart';
import '../services/settings_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ios_press.dart';
import '../widgets/section_header.dart';
import '../widgets/verse_notification_settings.dart';

/// Appearance, notification and playback settings.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool? _notificationsAllowed;
  bool? _batteryUnrestricted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-check after returning from Android settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final app = context.read<AppState>();
    final n = await app.notifications.areEnabled();
    final b = await NativeBridge.instance.isIgnoringBatteryOptimizations();
    if (!mounted) return;
    setState(() {
      _notificationsAllowed = n;
      _batteryUnrestricted = b;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final settings = context.watch<SettingsService>();

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          if (_notificationsAllowed == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Card(
                color: context.palette.live.withValues(alpha: 0.15),
                child: ListTile(
                  leading: Icon(Icons.notifications_off_rounded, color: context.palette.live),
                  title: const Text('Notifications are turned off'),
                  subtitle: const Text('Tap to allow notifications'),
                  onTap: () async {
                    await app.notifications.requestPermission();
                    await app.rescheduleDailyVerses();
                    _refresh();
                  },
                ),
              ),
            ),
          const SectionHeader('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CupertinoSlidingSegmentedControl<ThemeMode>(
              groupValue: settings.themeMode,
              thumbColor: context.palette.accentFill,
              backgroundColor: context.palette.text.withValues(alpha: 0.07),
              padding: const EdgeInsets.all(3),
              children: {
                for (final (mode, label) in const [
                  (ThemeMode.system, 'System'),
                  (ThemeMode.light, 'Light'),
                  (ThemeMode.dark, 'Dark'),
                ])
                  mode: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: settings.themeMode == mode ? context.palette.onAccent : context.palette.text,
                      ),
                    ),
                  ),
              },
              onValueChanged: (m) {
                if (m != null) settings.setThemeMode(m);
              },
            ),
          ),
          const SectionHeader('Daily verse'),
          const VerseNotificationSettings(),
          const SectionHeader('Playback'),
          IosSwitchTile(
            leading: const Icon(Icons.picture_in_picture_alt_rounded),
            title: const Text('Picture-in-picture on leaving'),
            subtitle: const Text('Keep watching in a small window when you leave the app'),
            value: settings.autoPip,
            onChanged: (v) async {
              await settings.setAutoPip(v);
              app.player.setAutoPip(v);
            },
          ),
          ListTile(
            leading: const Icon(Icons.battery_saver_rounded),
            title: const Text('Battery optimisation'),
            subtitle: Text(
              _batteryUnrestricted == true
                  ? 'Unrestricted — background playback and notifications are reliable'
                  : 'May stop background playback or delay notifications. Tap to change.',
            ),
            onTap: _batteryUnrestricted == true ? null : NativeBridge.instance.openBatteryOptimizationSettings,
          ),
        ],
      ),
    );
  }
}

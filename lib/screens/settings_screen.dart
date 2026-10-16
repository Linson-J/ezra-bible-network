import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/native_bridge.dart';
import '../services/settings_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/verse_notification_settings.dart';

/// Notification and playback settings.
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
    final reminderCount = settings.reminders.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Notification settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          if (_notificationsAllowed == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Card(
                color: AppColors.live.withValues(alpha: 0.15),
                child: ListTile(
                  leading: const Icon(Icons.notifications_off_rounded, color: AppColors.live),
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
          const SectionHeader('Daily verse'),
          const VerseNotificationSettings(),
          const SectionHeader('Program reminders'),
          ListTile(
            leading: const Icon(Icons.alarm_rounded),
            title: Text(reminderCount == 0
                ? 'No reminders set'
                : '$reminderCount reminder${reminderCount == 1 ? '' : 's'} set'),
            subtitle: const Text('Tap the bell on the Schedule tab to add one'),
            trailing: reminderCount == 0
                ? null
                : TextButton(onPressed: app.clearAllReminders, child: const Text('Clear all')),
          ),
          const SectionHeader('Playback'),
          SwitchListTile(
            secondary: const Icon(Icons.picture_in_picture_alt_rounded),
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
            subtitle: Text(_batteryUnrestricted == true
                ? 'Unrestricted — background playback and notifications are reliable'
                : 'May stop background playback or delay notifications. Tap to change.'),
            onTap: _batteryUnrestricted == true
                ? null
                : NativeBridge.instance.openBatteryOptimizationSettings,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'ios_press.dart';

Future<void> _toggle(BuildContext context, bool v) async {
  final settings = context.read<SettingsService>();
  final app = context.read<AppState>();
  if (v && !await app.notifications.areEnabled()) {
    final granted = await app.notifications.requestPermission();
    if (!granted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications are blocked. Allow them in Android Settings › Apps.')),
      );
    }
  }
  await settings.setVerseNotificationsEnabled(v);
  await app.rescheduleDailyVerses();
}

Future<void> _pickTime(BuildContext context) async {
  final settings = context.read<SettingsService>();
  final app = context.read<AppState>();
  final picked = await showIosTimePicker(
    context,
    initial: TimeOfDay(hour: settings.verseHour, minute: settings.verseMinute),
    title: 'Daily verse time',
  );
  if (picked == null) return;
  await settings.setVerseTime(picked.hour, picked.minute);
  await app.rescheduleDailyVerses();
}

/// Daily-verse notification on/off switch and time picker (Settings).
class VerseNotificationSettings extends StatelessWidget {
  const VerseNotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final enabled = settings.verseNotificationsEnabled;

    return Column(
      children: [
        IosSwitchTile(
          leading: const Icon(Icons.notifications_none_rounded),
          title: const Text('Daily verse notification'),
          subtitle: const Text('A new verse every morning'),
          value: enabled,
          onChanged: (v) => _toggle(context, v),
        ),
        ListTile(
          enabled: enabled,
          leading: const Icon(Icons.schedule_rounded),
          title: const Text('Notification time'),
          subtitle: const Text('In your device\'s time zone'),
          trailing: Text(
            formatTime(context, settings.verseHour, settings.verseMinute),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          onTap: enabled ? () => _pickTime(context) : null,
        ),
      ],
    );
  }
}

/// "Morning verse / Notification every day at 6:30 AM" row on the Verse tab.
/// Tap the text to change the time.
class MorningVerseRow extends StatelessWidget {
  const MorningVerseRow({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final p = context.palette;
    final enabled = settings.verseNotificationsEnabled;
    final time = formatTime(context, settings.verseHour, settings.verseMinute);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _pickTime(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.verseHour < 12 ? 'Morning verse' : 'Daily verse',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: p.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    enabled ? 'Notification every day at $time' : 'Notifications off',
                    style: TextStyle(fontSize: 15, color: p.textMuted),
                  ),
                ],
              ),
            ),
          ),
          IosSwitch(value: enabled, onChanged: (v) => _toggle(context, v)),
        ],
      ),
    );
  }
}

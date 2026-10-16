import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';

/// Daily-verse notification on/off switch and time picker.
class VerseNotificationSettings extends StatelessWidget {
  const VerseNotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final app = context.read<AppState>();
    final enabled = settings.verseNotificationsEnabled;

    Future<void> toggle(bool v) async {
      if (v && !await app.notifications.areEnabled()) {
        final granted = await app.notifications.requestPermission();
        if (!granted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Notifications are blocked. Allow them in Android Settings › Apps.'),
          ));
        }
      }
      await settings.setVerseNotificationsEnabled(v);
      await app.rescheduleDailyVerses();
    }

    Future<void> pickTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: settings.verseHour, minute: settings.verseMinute),
        helpText: 'Daily verse time',
      );
      if (picked == null) return;
      await settings.setVerseTime(picked.hour, picked.minute);
      await app.rescheduleDailyVerses();
    }

    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_rounded),
          title: const Text('Daily verse notification'),
          subtitle: const Text('A new verse every morning'),
          value: enabled,
          onChanged: toggle,
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
          onTap: enabled ? pickTime : null,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../models/program.dart';
import '../services/settings_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/minute_ticker.dart';
import '../widgets/program_tile.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday;
    return DefaultTabController(
      length: 7,
      initialIndex: today - 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (var d = 1; d <= 7; d++)
                Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(weekdayShort[d - 1]),
                      if (d == today)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: [for (var d = 1; d <= 7; d++) _DayList(weekday: d)],
        ),
      ),
    );
  }
}

class _DayList extends StatelessWidget {
  const _DayList({required this.weekday});
  final int weekday;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final settings = context.watch<SettingsService>();

    if (app.scheduleError != null && app.schedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(app.scheduleError!, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            FilledButton(onPressed: app.reloadSchedule, child: const Text('Retry')),
          ],
        ),
      );
    }

    final programs = app.programsFor(weekday);
    if (programs.isEmpty) {
      return const Center(
        child: Text('No programs scheduled.', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return MinuteTicker(
      builder: (context, now) {
        final current = app.currentProgram(now);
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: programs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final p = programs[i];
            return ProgramTile(
              program: p,
              isCurrent: p == current,
              hasReminder: settings.hasReminder(p.id),
              onToggleReminder: () => _toggleReminder(context, app, p, !settings.hasReminder(p.id)),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleReminder(BuildContext context, AppState app, Program p, bool on) async {
    final messenger = ScaffoldMessenger.of(context);
    final when = '${weekdayLong[p.dayOfWeek - 1]} ${formatHhmm(context, p.startTime)}';
    final ok = await app.setReminder(p, on);
    messenger.hideCurrentSnackBar();
    if (!ok) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Allow notifications in Android Settings › Apps to get reminders.'),
      ));
      return;
    }
    messenger.showSnackBar(SnackBar(
      content: Text(on
          ? 'We\'ll remind you ${AppConstants.reminderLeadTime.inMinutes} minutes before '
              '${p.title} every $when.'
          : 'Reminder for ${p.title} removed.'),
    ));
  }
}

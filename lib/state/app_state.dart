import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/app_constants.dart';
import '../config/env.dart';
import '../models/app_config.dart';
import '../models/app_content.dart';
import '../models/program.dart';
import '../models/verse.dart';
import '../repositories/repository_provider.dart';
import '../services/notification_service.dart';
import '../services/player_service.dart';
import '../services/settings_service.dart';

/// App-wide data loaded through the repositories, plus the long-lived player.
class AppState extends ChangeNotifier {
  AppState({required this.repos, required this.settings, NotificationService? notifications})
      : notifications = notifications ?? NotificationService.instance;

  final Repositories repos;
  final SettingsService settings;
  final NotificationService notifications;

  AppConfig config = const AppConfig();
  AppContent content = const AppContent();
  List<Program> schedule = const [];
  Verse? todayVerse;
  DateTime? _verseDate;
  String appVersion = '';
  String? scheduleError;

  PlayerService? _player;
  PlayerService get player => _player!;

  /// Selected bottom-navigation tab.
  final ValueNotifier<int> tab = ValueNotifier(0);

  bool get updateRequired => config.forceUpdate && config.requiresUpdate(appVersion);

  /// Config stream URLs win when set; otherwise .env.
  List<String> get streamUrls {
    final primary = config.streamUrl.isNotEmpty ? config.streamUrl : Env.streamUrl;
    final backup =
        config.streamBackupUrl.isNotEmpty ? config.streamBackupUrl : (Env.streamBackupUrl ?? '');
    return [primary, if (backup.isNotEmpty && backup != primary) backup];
  }

  /// Called once from the splash screen.
  Future<void> bootstrap() async {
    await notifications.init();
    final info = await PackageInfo.fromPlatform();
    appVersion = info.version;

    await Future.wait([
      _loadConfig(),
      _loadContent(),
      _loadSchedule(),
      refreshTodayVerse(),
    ]);

    _player = PlayerService(
      urls: streamUrls,
      title: AppConstants.appName,
      offAir: !config.isLive,
      autoPip: settings.autoPip,
    );

    // Fire-and-forget: keep notification scheduling off the startup path.
    rescheduleDailyVerses();
    _resyncReminders();
    notifyListeners();
  }

  Future<void> _loadConfig() async {
    try {
      config = await repos.config.getConfig();
    } catch (e) {
      debugPrint('Config load failed: $e');
    }
  }

  Future<void> _loadContent() async {
    try {
      content = await repos.content.getContent();
    } catch (e) {
      debugPrint('Content load failed: $e');
    }
  }

  Future<void> _loadSchedule() async {
    try {
      schedule = await repos.schedule.getSchedule();
      scheduleError = null;
    } catch (e) {
      scheduleError = 'Could not load the schedule.';
      debugPrint('Schedule load failed: $e');
    }
  }

  Future<void> reloadSchedule() async {
    await _loadSchedule();
    notifyListeners();
  }

  /// Loads today's verse if it isn't loaded yet or the date has changed.
  Future<void> refreshTodayVerse() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (todayVerse != null && _verseDate == today) return;
    try {
      todayVerse = await repos.verse.getVerseFor(today);
      _verseDate = today;
      notifyListeners();
    } catch (e) {
      debugPrint('Verse load failed: $e');
    }
  }

  /// Call when the app returns to the foreground.
  Future<void> onResume() async {
    await refreshTodayVerse();
    await rescheduleDailyVerses();
  }

  // ------------------------------------------------------------------ Schedule

  List<Program> programsFor(int weekday) =>
      schedule.where((p) => p.dayOfWeek == weekday).toList()
        ..sort((a, b) => a.startMinuteOfDay.compareTo(b.startMinuteOfDay));

  Program? currentProgram(DateTime now) {
    for (final p in schedule) {
      if (p.isOnAirAt(now)) return p;
    }
    return null;
  }

  Program? nextProgram(DateTime now) {
    final current = currentProgram(now);
    Program? best;
    for (final p in schedule) {
      if (p == current) continue;
      if (best == null || p.minutesUntilStart(now) < best.minutesUntilStart(now)) best = p;
    }
    return best;
  }

  // --------------------------------------------------------------- Notifications

  /// Schedules the next [AppConstants.verseDaysAhead] days of verse notifications
  /// (each day's text differs, so they're scheduled individually).
  Future<void> rescheduleDailyVerses() async {
    try {
      if (!settings.verseNotificationsEnabled) {
        await notifications.cancelDailyVerses();
        return;
      }
      final now = DateTime.now();
      final verses = await repos.verse.getVerses(
        from: DateTime(now.year, now.month, now.day),
        days: AppConstants.verseDaysAhead,
      );
      await notifications.scheduleDailyVerses(verses, settings.verseHour, settings.verseMinute);
    } catch (e) {
      debugPrint('Scheduling daily verses failed: $e');
    }
  }

  /// Re-applies saved reminders against the current schedule (times may have
  /// changed) and drops reminders for programs that no longer exist.
  Future<void> _resyncReminders() async {
    if (schedule.isEmpty) return;
    final byId = {for (final p in schedule) p.id: p};
    for (final id in settings.reminders) {
      final p = byId[id];
      try {
        if (p == null) {
          await notifications.cancelProgramReminder(id);
          await settings.setReminder(id, false);
        } else {
          await notifications.scheduleProgramReminder(p);
        }
      } catch (e) {
        debugPrint('Reminder resync failed for $id: $e');
      }
    }
  }

  /// Returns false if notifications aren't permitted (nothing scheduled).
  Future<bool> setReminder(Program p, bool on) async {
    if (on) {
      if (!await notifications.areEnabled() && !await notifications.requestPermission()) {
        return false;
      }
      await notifications.scheduleProgramReminder(p);
    } else {
      await notifications.cancelProgramReminder(p.id);
    }
    await settings.setReminder(p.id, on);
    return true;
  }

  Future<void> clearAllReminders() async {
    for (final id in settings.reminders) {
      await notifications.cancelProgramReminder(id);
      await settings.setReminder(id, false);
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    tab.dispose();
    super.dispose();
  }
}

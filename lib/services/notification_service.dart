import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../config/app_constants.dart';
import '../models/program.dart';
import '../models/verse.dart';

/// Local notifications: daily verses and program reminders.
///
/// Everything uses inexact alarms (no SCHEDULE_EXACT_ALARM permission), so
/// Android may deliver a notification a few minutes late. Scheduled
/// notifications survive reboots via the plugin's boot receiver
/// (declared in AndroidManifest.xml).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();
  bool _initialized = false;

  /// Payloads of notifications the user tapped while the app was running.
  Stream<String> get taps => _taps.stream;

  /// Payload of the notification that launched the app, if any. Read once.
  String? takeLaunchPayload() {
    final p = _launchPayload;
    _launchPayload = null;
    return p;
  }

  String? _launchPayload;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  Future<void> init() async {
    if (_initialized) return;
    await _initTimezone();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
      ),
      onDidReceiveNotificationResponse: (r) => _taps.add(r.payload ?? ''),
    );

    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _launchPayload = launch!.notificationResponse?.payload;
    }

    await _android?.createNotificationChannel(const AndroidNotificationChannel(
      AppConstants.verseChannelId,
      AppConstants.verseChannelName,
      description: 'A Bible verse every morning',
      importance: Importance.defaultImportance,
    ));
    await _android?.createNotificationChannel(const AndroidNotificationChannel(
      AppConstants.reminderChannelId,
      AppConstants.reminderChannelName,
      description: 'Reminders 10 minutes before programs you chose',
      importance: Importance.high,
    ));
    _initialized = true;
  }

  Future<void> _initTimezone() async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      // Unknown identifier: pick any zone with the device's current offset.
      final offset = DateTime.now().timeZoneOffset.inMilliseconds;
      final match = tz.timeZoneDatabase.locations.values.firstWhere(
        (l) => l.currentTimeZone.offset == offset,
        orElse: () => tz.UTC,
      );
      tz.setLocalLocation(match);
      debugPrint('Timezone fallback to ${match.name}: $e');
    }
  }

  /// Shows the Android 13+ permission dialog. Returns whether notifications are allowed.
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  Future<bool> areEnabled() async => await _android?.areNotificationsEnabled() ?? false;

  // ---------------------------------------------------------------- Daily verse

  /// Replaces the scheduled daily-verse notifications with one per verse, at
  /// [hour]:[minute] local time on each verse's date. Past times are skipped.
  Future<int> scheduleDailyVerses(List<Verse> verses, int hour, int minute) async {
    await cancelDailyVerses();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = 0;
    for (var i = 0; i < verses.length && i < AppConstants.verseDaysAhead; i++) {
      final v = verses[i];
      final d = v.date ?? DateTime(now.year, now.month, now.day + i);
      final when = tz.TZDateTime(tz.local, d.year, d.month, d.day, hour, minute);
      if (!when.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        id: AppConstants.verseNotificationBaseId + i,
        title: 'Verse of the Day · ${v.reference}',
        body: v.text,
        scheduledDate: when,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.verseChannelId,
            AppConstants.verseChannelName,
            styleInformation: BigTextStyleInformation(v.text),
            icon: '@drawable/ic_notification',
            color: _gold,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: AppConstants.payloadVerse,
      );
      scheduled++;
    }
    return scheduled;
  }

  Future<void> cancelDailyVerses() async {
    for (var i = 0; i < AppConstants.verseDaysAhead; i++) {
      await _plugin.cancel(id: AppConstants.verseNotificationBaseId + i);
    }
  }

  // ------------------------------------------------------------ Program reminders

  /// Stable id per program (String.hashCode is not stable across runs).
  static int reminderId(String programId) {
    var h = 0x811c9dc5;
    for (final c in programId.codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0x7fffffff;
    }
    return AppConstants.reminderNotificationBaseId + h % 1000000;
  }

  /// Weekly reminder [AppConstants.reminderLeadTime] before [p] starts.
  Future<void> scheduleProgramReminder(Program p) async {
    final now = tz.TZDateTime.now(tz.local);
    final daysAhead = (p.dayOfWeek - now.weekday) % 7;
    var when = tz.TZDateTime(
      tz.local, now.year, now.month, now.day + daysAhead, p.startHour, p.startMinute,
    ).subtract(AppConstants.reminderLeadTime);
    while (!when.isAfter(now)) {
      when = tz.TZDateTime(tz.local, when.year, when.month, when.day + 7, when.hour, when.minute);
    }
    final speaker = p.speaker.isEmpty ? '' : ' with ${p.speaker}';
    await _plugin.zonedSchedule(
      id: reminderId(p.id),
      title: '${p.title} starts in ${AppConstants.reminderLeadTime.inMinutes} minutes',
      body: 'Watch live$speaker at ${p.startTime} on Ezra Bible Network.',
      scheduledDate: when,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.reminderChannelId,
          AppConstants.reminderChannelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          color: _gold,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: AppConstants.payloadLive,
    );
  }

  Future<void> cancelProgramReminder(String programId) =>
      _plugin.cancel(id: reminderId(programId));
}

/// Accent colour for notification icons (gold).
const _gold = Color(0xFFD4AF37);

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_constants.dart';
import '../config/env.dart';

/// User preferences persisted in SharedPreferences.
class SettingsService extends ChangeNotifier {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static Future<SettingsService> load() async =>
      SettingsService(await SharedPreferences.getInstance());

  bool get verseNotificationsEnabled => _prefs.getBool(AppConstants.prefVerseEnabled) ?? true;
  int get verseHour => _prefs.getInt(AppConstants.prefVerseHour) ?? Env.dailyVerseHour;
  int get verseMinute => _prefs.getInt(AppConstants.prefVerseMinute) ?? Env.dailyVerseMinute;

  Future<void> setVerseNotificationsEnabled(bool v) async {
    await _prefs.setBool(AppConstants.prefVerseEnabled, v);
    notifyListeners();
  }

  Future<void> setVerseTime(int hour, int minute) async {
    await _prefs.setInt(AppConstants.prefVerseHour, hour);
    await _prefs.setInt(AppConstants.prefVerseMinute, minute);
    notifyListeners();
  }

  bool get autoPip => _prefs.getBool(AppConstants.prefAutoPip) ?? true;

  Future<void> setAutoPip(bool v) async {
    await _prefs.setBool(AppConstants.prefAutoPip, v);
    notifyListeners();
  }

  /// Program ids with a "Remind me" set.
  Set<String> get reminders => (_prefs.getStringList(AppConstants.prefReminders) ?? const []).toSet();

  bool hasReminder(String programId) => reminders.contains(programId);

  Future<void> setReminder(String programId, bool on) async {
    final set = reminders;
    on ? set.add(programId) : set.remove(programId);
    await _prefs.setStringList(AppConstants.prefReminders, set.toList());
    notifyListeners();
  }

  bool get batteryPromptShown => _prefs.getBool(AppConstants.prefBatteryPromptShown) ?? false;
  Future<void> markBatteryPromptShown() =>
      _prefs.setBool(AppConstants.prefBatteryPromptShown, true);

  bool get notificationPromptShown =>
      _prefs.getBool(AppConstants.prefNotificationPromptShown) ?? false;
  Future<void> markNotificationPromptShown() =>
      _prefs.setBool(AppConstants.prefNotificationPromptShown, true);
}

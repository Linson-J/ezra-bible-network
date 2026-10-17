class AppConstants {
  AppConstants._();

  static const appName = 'Ezra Bible Network';
  static const packageName = 'com.ezrabiblenetwork.app';
  static const playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';
  static const playStoreMarketUrl = 'market://details?id=$packageName';

  static const nativeChannel = 'com.ezrabiblenetwork.app/native';

  // Player
  static const retryInterval = Duration(seconds: 10);

  // Reminders
  static const reminderLeadTime = Duration(minutes: 10);

  // Daily verse: how many days of individual notifications to keep scheduled.
  static const verseDaysAhead = 30;

  // Notification ids. Ranges must not overlap.
  static const verseNotificationBaseId = 1000; // 1000..1029
  static const reminderNotificationBaseId = 100000; // 100000.. (hashed)

  // Notification channels
  static const verseChannelId = 'daily_verse';
  static const verseChannelName = 'Daily verse';
  static const reminderChannelId = 'program_reminders';
  static const reminderChannelName = 'Program reminders';

  // Notification payloads
  static const payloadVerse = 'verse';
  static const payloadLive = 'live';

  // SharedPreferences keys
  static const prefVerseEnabled = 'verse_notifications_enabled';
  static const prefVerseHour = 'verse_hour';
  static const prefVerseMinute = 'verse_minute';
  static const prefReminders = 'program_reminders';
  static const prefBatteryPromptShown = 'battery_prompt_shown';
  static const prefNotificationPromptShown = 'notification_prompt_shown';
  static const prefAutoPip = 'auto_pip';
  static const prefThemeMode = 'theme_mode';
}

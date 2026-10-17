import 'package:flutter/material.dart';

const weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const weekdayLong = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// "Friday, 16 October"
String formatLongDate(DateTime d) => '${weekdayLong[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

/// Formats "HH:mm" using the device's 12/24-hour preference.
String formatHhmm(BuildContext context, String hhmm) {
  final p = hhmm.split(':');
  return formatTime(context, int.parse(p[0]), int.parse(p[1]));
}

String formatTime(BuildContext context, int hour, int minute) {
  final loc = MaterialLocalizations.of(context);
  return loc.formatTimeOfDay(
    TimeOfDay(hour: hour, minute: minute),
    alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
  );
}

/// "SATURDAY · 17 OCTOBER"
String formatEyebrowDate(DateTime d) =>
    '${weekdayLong[d.weekday - 1]} · ${d.day} ${_months[d.month - 1]}'.toUpperCase();

/// "Pr. Name · until 11:30 AM"
String speakerUntil(BuildContext context, String speaker, String endHhmm) =>
    [if (speaker.isNotEmpty) speaker, 'until ${formatHhmm(context, endHhmm)}'].join(' · ');

/// "Today", "Yesterday", "3 days ago", "2 weeks ago", "16 Oct".
String timeAgo(DateTime t, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final days = DateTime(n.year, n.month, n.day).difference(DateTime(t.year, t.month, t.day)).inDays;
  if (days <= 0) return 'Today';
  if (days == 1) return 'Yesterday';
  if (days < 7) return '$days days ago';
  if (days < 28) return '${days ~/ 7} week${days < 14 ? '' : 's'} ago';
  return '${t.day} ${_months[t.month - 1].substring(0, 3)}';
}

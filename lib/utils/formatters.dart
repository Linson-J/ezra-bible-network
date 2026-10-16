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

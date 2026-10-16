/// A scheduled program. [dayOfWeek] follows [DateTime.weekday]: 1 = Monday … 7 = Sunday.
/// Times are "HH:mm" in the device's local time. A program whose end is not after
/// its start runs past midnight into the next day.
class Program {
  const Program({
    required this.id,
    required this.title,
    required this.speaker,
    required this.description,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.thumbnailUrl = '',
  });

  final String id;
  final String title;
  final String speaker;
  final String description;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String thumbnailUrl;

  factory Program.fromJson(Map<String, dynamic> json) => Program(
        id: json['id'].toString(),
        title: json['title'] as String? ?? '',
        speaker: json['speaker'] as String? ?? '',
        description: json['description'] as String? ?? '',
        dayOfWeek: (json['dayOfWeek'] as num).toInt(),
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'speaker': speaker,
        'description': description,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'thumbnailUrl': thumbnailUrl,
      };

  static int _minutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  int get startMinuteOfDay => _minutes(startTime);
  int get startHour => startMinuteOfDay ~/ 60;
  int get startMinute => startMinuteOfDay % 60;

  int get durationMinutes {
    final d = _minutes(endTime) - startMinuteOfDay;
    return d > 0 ? d : d + 24 * 60;
  }

  static const minutesPerWeek = 7 * 24 * 60;

  /// Minutes since Monday 00:00 at which this program starts.
  int get startMinuteOfWeek => (dayOfWeek - 1) * 24 * 60 + startMinuteOfDay;

  static int minuteOfWeek(DateTime t) => (t.weekday - 1) * 24 * 60 + t.hour * 60 + t.minute;

  bool isOnAirAt(DateTime t) {
    final elapsed = (minuteOfWeek(t) - startMinuteOfWeek) % minutesPerWeek;
    return elapsed < durationMinutes;
  }

  /// Minutes from [t] until the next start (0 < result <= one week).
  int minutesUntilStart(DateTime t) {
    final m = (startMinuteOfWeek - minuteOfWeek(t)) % minutesPerWeek;
    return m == 0 ? minutesPerWeek : m;
  }
}

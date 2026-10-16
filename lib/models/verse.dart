/// A daily verse. Local data identifies it by [day] (day of year, 1–366);
/// the API identifies it by [date].
class Verse {
  const Verse({
    required this.reference,
    required this.text,
    this.day,
    this.date,
  });

  final String reference;
  final String text;
  final int? day;
  final DateTime? date;

  factory Verse.fromJson(Map<String, dynamic> json) => Verse(
        reference: json['reference'] as String,
        text: json['text'] as String,
        day: (json['day'] as num?)?.toInt(),
        date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {
        if (day != null) 'day': day,
        if (date != null) 'date': formatDate(date!),
        'reference': reference,
        'text': text,
      };

  Verse withDate(DateTime d) => Verse(reference: reference, text: text, day: day, date: d);

  String get shareText => '"$text"\n— $reference';

  static String formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 1 for Jan 1 … 366 for Dec 31 in a leap year.
  static int dayOfYear(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(d.year, 1, 1)).inDays + 1;
}

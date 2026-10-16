class PrayerRequest {
  const PrayerRequest({required this.name, required this.phone, required this.request});

  final String name;
  final String phone;
  final String request;

  factory PrayerRequest.fromJson(Map<String, dynamic> json) => PrayerRequest(
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        request: json['request'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone, 'request': request};

  /// Human-readable message used when sending via WhatsApp or email.
  String toMessage() {
    final b = StringBuffer('Prayer request\n\n');
    if (name.trim().isNotEmpty) b.writeln('Name: ${name.trim()}');
    if (phone.trim().isNotEmpty) b.writeln('Phone: ${phone.trim()}');
    b
      ..writeln()
      ..write(request.trim());
    return b.toString();
  }
}

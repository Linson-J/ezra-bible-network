import '../models/prayer_request.dart';

abstract class PrayerRepository {
  /// Whether [submit] sends the request to a backend. When false, the UI
  /// sends it via WhatsApp or email instead.
  bool get supportsDirectSubmit;

  Future<void> submit(PrayerRequest request);
}

import '../../models/prayer_request.dart';
import '../prayer_repository.dart';

/// No backend yet: the UI sends prayer requests via WhatsApp or email.
class LocalPrayerRepository implements PrayerRepository {
  @override
  bool get supportsDirectSubmit => false;

  @override
  Future<void> submit(PrayerRequest request) => throw UnsupportedError(
      'Prayer requests are sent via WhatsApp or email until a backend exists.');
}

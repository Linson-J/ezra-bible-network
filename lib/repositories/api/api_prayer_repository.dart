import '../../models/prayer_request.dart';
import '../prayer_repository.dart';
import 'api_client.dart';

/// POST /api/prayer-requests { name, phone, request } -> 201
class ApiPrayerRepository implements PrayerRepository {
  ApiPrayerRepository(this._api);
  final ApiClient _api;

  @override
  bool get supportsDirectSubmit => true;

  @override
  Future<void> submit(PrayerRequest request) =>
      _api.post('/api/prayer-requests', request.toJson());
}

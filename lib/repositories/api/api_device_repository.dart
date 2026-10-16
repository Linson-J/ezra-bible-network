import '../device_repository.dart';
import 'api_client.dart';

/// POST /api/devices { fcmToken, platform } -> 201
class ApiDeviceRepository implements DeviceRepository {
  ApiDeviceRepository(this._api);
  final ApiClient _api;

  @override
  Future<void> registerDevice({required String fcmToken, String platform = 'android'}) =>
      _api.post('/api/devices', {'fcmToken': fcmToken, 'platform': platform});
}

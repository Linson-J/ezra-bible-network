import '../device_repository.dart';

/// No-op until push notifications are added.
class LocalDeviceRepository implements DeviceRepository {
  @override
  Future<void> registerDevice({required String fcmToken, String platform = 'android'}) async {}
}

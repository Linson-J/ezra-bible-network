/// Registers this device for push notifications (future use).
abstract class DeviceRepository {
  Future<void> registerDevice({required String fcmToken, String platform = 'android'});
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../config/app_constants.dart';

/// Talks to MainActivity.kt: picture-in-picture, the playback foreground
/// service and battery-optimisation settings.
class NativeBridge {
  NativeBridge._() {
    _channel.setMethodCallHandler(_onCall);
  }
  static final NativeBridge instance = NativeBridge._();

  final _channel = const MethodChannel(AppConstants.nativeChannel);

  /// Emits true when the activity enters PiP, false when it leaves.
  final ValueNotifier<bool> inPip = ValueNotifier(false);

  Future<dynamic> _onCall(MethodCall call) async {
    if (call.method == 'pipChanged') inPip.value = call.arguments == true;
  }

  Future<T?> _invoke<T>(String method, [Map<String, dynamic>? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null; // e.g. widget tests
    } on PlatformException catch (e) {
      debugPrint('NativeBridge.$method failed: $e');
      return null;
    }
  }

  Future<bool> isPipSupported() async => await _invoke<bool>('isPipSupported') ?? false;
  Future<bool> enterPip() async => await _invoke<bool>('enterPip') ?? false;
  Future<void> setAutoPip(bool enabled) => _invoke('setAutoPip', {'enabled': enabled});

  Future<void> startPlaybackService(String title) =>
      _invoke('startPlaybackService', {'title': title});
  Future<void> stopPlaybackService() => _invoke('stopPlaybackService');

  Future<bool> isIgnoringBatteryOptimizations() async =>
      await _invoke<bool>('isIgnoringBatteryOptimizations') ?? true;
  Future<bool> openBatteryOptimizationSettings() async =>
      await _invoke<bool>('openBatteryOptimizationSettings') ?? false;
}

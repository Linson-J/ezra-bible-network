import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../config/app_constants.dart';
import 'native_bridge.dart';

enum PlayerStatus {
  /// Preparing the stream.
  loading,

  /// Stream is prepared (playing or paused).
  ready,

  /// The stream failed; an automatic retry is scheduled.
  error,

  /// No network connection; retries continue and resume on reconnect.
  offline,

  /// The broadcaster reports it is not live (AppConfig.isLive == false).
  offAir,
}

/// Owns the live-stream player for the lifetime of the app.
///
/// - Tries [urls] in order (primary, then backup) and retries every
///   [AppConstants.retryInterval] after both fail.
/// - Keeps playing in the background with a media notification; a native
///   foreground service keeps the process alive.
/// - Supports PiP (manual and automatic when leaving the app), fullscreen,
///   "Go Live" and an audio-only mode.
class PlayerService extends ChangeNotifier with WidgetsBindingObserver {
  PlayerService({
    required List<String> urls,
    required this.title,
    bool offAir = false,
    bool autoPip = true,
  })  : urls = urls.where((u) => u.isNotEmpty).toList(),
        _autoPip = autoPip,
        _status = offAir ? PlayerStatus.offAir : PlayerStatus.loading {
    assert(this.urls.isNotEmpty, 'At least one stream URL is required');
  }

  final List<String> urls;
  final String title;
  final _native = NativeBridge.instance;
  final _connectivity = Connectivity();

  /// Keeps the BetterPlayer widget's state when it moves between layouts
  /// (normal ↔ PiP).
  final GlobalKey playerKey = GlobalKey();

  BetterPlayerController? _controller;
  BetterPlayerController? get controller => _controller;

  PlayerStatus _status;
  PlayerStatus get status => _status;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _isBuffering = false;
  bool get isBuffering => _isBuffering;

  /// True after the user paused: playback is no longer at the live edge.
  bool _behindLive = false;
  bool get isBehindLive => _behindLive;

  bool _audioOnly = false;
  bool get audioOnly => _audioOnly;

  bool get inPip => _native.inPip.value;

  bool _pipSupported = false;
  bool get pipSupported => _pipSupported;

  bool _autoPip;

  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;

  int _retryIn = 0;

  /// Seconds until the next automatic retry (0 when none is scheduled).
  int get retryInSeconds => _retryIn;

  String? _lastError;
  String? get lastError => _lastError;

  int _urlIndex = 0;
  Timer? _retryTimer;
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;
  bool _started = false;
  bool _disposed = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _native.inPip.addListener(_onPipChanged);
    _pipSupported = await _native.isPipSupported();

    _connSub = _connectivity.onConnectivityChanged.listen(_onConnectivity);
    try {
      _hasConnection = _isConnected(await _connectivity.checkConnectivity());
    } catch (_) {
      _hasConnection = true;
    }

    if (_status == PlayerStatus.offAir) {
      _notify();
      return;
    }
    if (!_hasConnection) {
      _failed('No internet connection');
      return;
    }
    await _load();
  }

  BetterPlayerConfiguration _configuration() => BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoPlay: false,
        // We handle lifecycle ourselves so the stream keeps playing in the background.
        handleLifecycle: false,
        autoDispose: false,
        allowedScreenSleep: false,
        deviceOrientationsOnFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: const [DeviceOrientation.portraitUp],
        systemOverlaysAfterFullScreen: SystemUiOverlay.values,
        // Our own overlay (OfflineView) shows errors.
        errorBuilder: (context, message) => const SizedBox.shrink(),
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enableSkips: false,
          enableProgressBar: false,
          enableProgressText: false,
          enablePlaybackSpeed: false,
          enableSubtitles: false,
          enableAudioTracks: false,
          enablePip: false,
          enableRetry: false,
          enableQualities: true,
          enableOverflowMenu: true,
          liveTextColor: Colors.transparent, // We draw our own LIVE badge.
          loadingColor: Color(0xFF7CCFF5),
          progressBarPlayedColor: Color(0xFF7CCFF5),
          progressBarHandleColor: Color(0xFF7CCFF5),
          controlBarColor: Color(0x99000000),
        ),
      );

  BetterPlayerDataSource _dataSource(String url) => BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
        liveStream: true,
        videoFormat: BetterPlayerVideoFormat.hls,
        useAsmsSubtitles: false,
        useAsmsAudioTracks: false,
        notificationConfiguration: BetterPlayerNotificationConfiguration(
          showNotification: true,
          title: title,
          author: 'Live',
          activityName: 'MainActivity',
        ),
      );

  Future<void> _load({bool autoPlay = true}) async {
    if (_disposed) return;
    _cancelRetry();
    _status = PlayerStatus.loading;
    _lastError = null;
    _notify();

    final gen = ++_loadGen;
    final url = urls[_urlIndex];
    try {
      if (_controller == null) {
        _controller = BetterPlayerController(_configuration());
        _controller!.addEventsListener(_onEvent);
      }
      // Completes once the stream is prepared; throws if it can't be loaded.
      await _controller!.setupDataSource(_dataSource(url));
      if (_disposed || gen != _loadGen) return;
      _status = PlayerStatus.ready;
      _readySince = DateTime.now();
      _behindLive = false;
      if (_audioOnly) _applyAudioOnlyTrack();
      if (autoPlay) await _controller!.play();
      _notify();
    } catch (e) {
      if (gen == _loadGen) _onError('$e');
    }
  }

  int _loadGen = 0;
  DateTime? _readySince;

  void _onEvent(BetterPlayerEvent event) {
    if (_disposed) return;
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.play:
        _setPlaying(true);
      case BetterPlayerEventType.pause:
        _behindLive = true;
        _setPlaying(false);
      case BetterPlayerEventType.bufferingStart:
        _isBuffering = true;
      case BetterPlayerEventType.bufferingEnd:
        _isBuffering = false;
      // Failures while loading are handled by _load's catch.
      case BetterPlayerEventType.exception:
        if (_status == PlayerStatus.ready) {
          _onError(event.parameters?['exception']?.toString() ?? 'Playback error');
        }
        return;
      case BetterPlayerEventType.finished:
        // A live stream "finishing" means the broadcast stopped.
        if (_status == PlayerStatus.ready) _onError('The live stream ended');
        return;
      default:
        break;
    }
    _notify();
  }

  void _onError(String message) {
    if (_disposed) return;
    final wasRunning = _status == PlayerStatus.ready &&
        _readySince != null &&
        DateTime.now().difference(_readySince!) > AppConstants.retryInterval;
    _lastError = message;
    _isBuffering = false;
    _setPlaying(false);

    // Fell out of the live window (e.g. paused for a long time): just reload.
    if (message.contains('BehindLiveWindow')) {
      _load();
      return;
    }
    // A stream that had been playing dropped: start over from the primary URL.
    if (wasRunning) {
      _urlIndex = 0;
      _load();
      return;
    }
    if (_urlIndex < urls.length - 1) {
      _urlIndex++; // try the backup immediately
      _load();
      return;
    }
    _urlIndex = 0;
    _failed(message);
  }

  void _failed(String message) {
    _lastError = message;
    _status = _hasConnection ? PlayerStatus.error : PlayerStatus.offline;
    _scheduleRetry();
    _notify();
  }

  void _scheduleRetry() {
    _cancelRetry();
    _retryIn = AppConstants.retryInterval.inSeconds;
    _retryTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      _retryIn--;
      if (_retryIn <= 0) {
        t.cancel();
        _retryIn = 0;
        _load();
      } else {
        _notify();
      }
    });
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryIn = 0;
  }

  static bool _isConnected(List<ConnectivityResult> r) =>
      r.any((c) => c != ConnectivityResult.none);

  void _onConnectivity(List<ConnectivityResult> results) {
    final connected = _isConnected(results);
    if (connected == _hasConnection) return;
    _hasConnection = connected;
    if (connected) {
      if (_status == PlayerStatus.error || _status == PlayerStatus.offline) _load();
    } else if (_status == PlayerStatus.error) {
      _status = PlayerStatus.offline;
    }
    _notify();
  }

  void _setPlaying(bool playing) {
    if (_isPlaying == playing) return;
    _isPlaying = playing;
    _syncPlatform();
  }

  /// Keeps auto-PiP, the foreground service and the wakelock in step with playback.
  void _syncPlatform() {
    _native.setAutoPip(_isPlaying && !_audioOnly && _autoPip && _pipSupported);
    if (_isPlaying) {
      _native.startPlaybackService(title);
    } else if (_lifecycle == AppLifecycleState.resumed) {
      // Paused from the lock screen keeps the service so "play" works there too.
      _native.stopPlaybackService();
    }
    final keepAwake = _isPlaying && !_audioOnly && _lifecycle == AppLifecycleState.resumed;
    WakelockPlus.toggle(enable: keepAwake).catchError((_) {});
  }

  // ------------------------------------------------------------------ Actions

  Future<void> togglePlay() async {
    final c = _controller;
    if (_status != PlayerStatus.ready || c == null) {
      retryNow();
      return;
    }
    if (_isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
  }

  /// Jumps back to the live edge by re-preparing the stream.
  Future<void> goLive() => _load();

  /// Ignores the retry countdown (and the off-air flag) and tries now.
  void retryNow() {
    _urlIndex = 0;
    _load();
  }

  Future<void> toggleAudioOnly() async {
    _audioOnly = !_audioOnly;
    _applyAudioOnlyTrack();
    _syncPlatform();
    _notify();
  }

  /// In audio-only mode pick the lowest-bitrate variant (saves data when the
  /// stream offers several); otherwise let the player choose adaptively.
  void _applyAudioOnlyTrack() {
    final c = _controller;
    if (c == null || c.videoPlayerController == null) return;
    final tracks = c.betterPlayerAsmsTracks.where((t) => (t.bitrate ?? 0) > 0).toList();
    if (_audioOnly && tracks.length > 1) {
      tracks.sort((a, b) => a.bitrate!.compareTo(b.bitrate!));
      c.setTrack(tracks.first);
    } else if (!_audioOnly && tracks.length > 1) {
      c.setTrack(BetterPlayerAsmsTrack.defaultTrack());
    }
  }

  Future<void> enterPip() async {
    if (!_pipSupported) return;
    if (!_isPlaying) await _controller?.play();
    await _native.enterPip();
  }

  void toggleFullScreen() => _controller?.toggleFullScreen();

  void setAutoPip(bool enabled) {
    _autoPip = enabled;
    _syncPlatform();
  }

  // ---------------------------------------------------------------- Lifecycle

  void _onPipChanged() {
    _controller?.setControlsEnabled(!_native.inPip.value);
    if (!_native.inPip.value) {
      // Closing the PiP window (rather than expanding it) leaves the activity
      // stopped; stop playback like other video apps do.
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_disposed && _lifecycle != AppLifecycleState.resumed && _isPlaying) {
          _controller?.pause();
        }
      });
    }
    _notify();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    if (state == AppLifecycleState.resumed && !_isPlaying) _native.stopPlaybackService();
    _syncPlatform();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelRetry();
    _connSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _native.inPip.removeListener(_onPipChanged);
    _native.setAutoPip(false);
    _native.stopPlaybackService();
    WakelockPlus.disable().catchError((_) {});
    _controller?.removeEventsListener(_onEvent);
    _controller?.dispose(forceDispose: true);
    super.dispose();
  }
}

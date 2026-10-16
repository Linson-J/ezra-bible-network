import 'package:flutter_dotenv/flutter_dotenv.dart';

enum DataSource { local, api }

/// Thrown when `.env` is missing or invalid. The message is shown on screen.
class EnvException implements Exception {
  EnvException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Typed access to values from the bundled `.env` file.
class Env {
  Env._();

  /// Loads `.env` and validates required keys. Throws [EnvException].
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      throw EnvException(
        'Could not load .env.\n\nCopy .env.example to .env in the project '
        'root, set STREAM_URL, then rebuild the app.\n\n($e)',
      );
    }
    _validate();
  }

  static void _validate() {
    final url = _get('STREAM_URL');
    if (url.isEmpty) {
      throw EnvException('STREAM_URL is missing in .env.\n\n'
          'Set it to your HLS (.m3u8) stream URL and rebuild.');
    }
    if (!_isHttpUrl(url)) {
      throw EnvException('STREAM_URL must be an http(s) HLS URL, got:\n$url\n\n'
          'RTMP ingest URLs cannot be played in the app.');
    }
    final backup = _get('STREAM_BACKUP_URL');
    if (backup.isNotEmpty && !_isHttpUrl(backup)) {
      throw EnvException('STREAM_BACKUP_URL must be an http(s) URL, got:\n$backup');
    }
    final source = _get('DATA_SOURCE', 'local');
    if (source != 'local' && source != 'api') {
      throw EnvException('DATA_SOURCE must be "local" or "api", got "$source".');
    }
    if (source == 'api' && apiBaseUrl.isEmpty) {
      throw EnvException('DATA_SOURCE=api requires API_BASE_URL in .env.');
    }
  }

  static bool _isHttpUrl(String s) {
    final uri = Uri.tryParse(s);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  static String _get(String key, [String fallback = '']) =>
      (dotenv.maybeGet(key) ?? fallback).trim();

  static int _int(String key, int fallback, int min, int max) {
    final v = int.tryParse(_get(key));
    if (v == null || v < min || v > max) return fallback;
    return v;
  }

  static String get streamUrl => _get('STREAM_URL');

  static String? get streamBackupUrl {
    final v = _get('STREAM_BACKUP_URL');
    return v.isEmpty ? null : v;
  }

  static DataSource get dataSource =>
      _get('DATA_SOURCE', 'local') == 'api' ? DataSource.api : DataSource.local;

  /// Base URL without trailing slash.
  static String get apiBaseUrl => _get('API_BASE_URL').replaceAll(RegExp(r'/+$'), '');

  static int get dailyVerseHour => _int('DAILY_VERSE_HOUR', 6, 0, 23);
  static int get dailyVerseMinute => _int('DAILY_VERSE_MINUTE', 30, 0, 59);
}

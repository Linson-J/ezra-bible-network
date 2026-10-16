/// Remote-controllable app configuration.
///
/// Empty [streamUrl]/[streamBackupUrl] mean "use the values from .env".
class AppConfig {
  const AppConfig({
    this.streamUrl = '',
    this.streamBackupUrl = '',
    this.isLive = true,
    this.offlineMessage = '',
    this.announcement = '',
    this.minAppVersion = '',
    this.forceUpdate = false,
    this.donationUrl = '',
  });

  final String streamUrl;
  final String streamBackupUrl;
  final bool isLive;
  final String offlineMessage;
  final String announcement;
  final String minAppVersion;
  final bool forceUpdate;
  final String donationUrl;

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
        streamUrl: json['streamUrl'] as String? ?? '',
        streamBackupUrl: json['streamBackupUrl'] as String? ?? '',
        isLive: json['isLive'] as bool? ?? true,
        offlineMessage: json['offlineMessage'] as String? ?? '',
        announcement: json['announcement'] as String? ?? '',
        minAppVersion: json['minAppVersion'] as String? ?? '',
        forceUpdate: json['forceUpdate'] as bool? ?? false,
        donationUrl: json['donationUrl'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'streamUrl': streamUrl,
        'streamBackupUrl': streamBackupUrl,
        'isLive': isLive,
        'offlineMessage': offlineMessage,
        'announcement': announcement,
        'minAppVersion': minAppVersion,
        'forceUpdate': forceUpdate,
        'donationUrl': donationUrl,
      };

  /// True when [current] (e.g. "1.2.3") is older than [minAppVersion].
  bool requiresUpdate(String current) {
    if (minAppVersion.isEmpty) return false;
    List<int> parse(String v) =>
        v.split('+').first.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final a = parse(current), b = parse(minAppVersion);
    for (var i = 0; i < 3; i++) {
      final x = i < a.length ? a[i] : 0, y = i < b.length ? b[i] : 0;
      if (x != y) return x < y;
    }
    return false;
  }
}

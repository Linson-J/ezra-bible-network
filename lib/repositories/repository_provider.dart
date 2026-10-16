import '../config/env.dart';
import 'api/api_client.dart';
import 'api/api_config_repository.dart';
import 'api/api_content_repository.dart';
import 'api/api_device_repository.dart';
import 'api/api_prayer_repository.dart';
import 'api/api_schedule_repository.dart';
import 'api/api_verse_repository.dart';
import 'config_repository.dart';
import 'content_repository.dart';
import 'device_repository.dart';
import 'local/local_config_repository.dart';
import 'local/local_content_repository.dart';
import 'local/local_device_repository.dart';
import 'local/local_prayer_repository.dart';
import 'local/local_schedule_repository.dart';
import 'local/local_verse_repository.dart';
import 'prayer_repository.dart';
import 'schedule_repository.dart';
import 'verse_repository.dart';

/// All data access goes through these repositories. The implementation is
/// chosen once from DATA_SOURCE in .env (local JSON assets or the HTTP API).
class Repositories {
  const Repositories({
    required this.schedule,
    required this.verse,
    required this.content,
    required this.config,
    required this.prayer,
    required this.device,
  });

  final ScheduleRepository schedule;
  final VerseRepository verse;
  final ContentRepository content;
  final ConfigRepository config;
  final PrayerRepository prayer;
  final DeviceRepository device;

  factory Repositories.fromEnv() {
    switch (Env.dataSource) {
      case DataSource.local:
        return Repositories(
          schedule: LocalScheduleRepository(),
          verse: LocalVerseRepository(),
          content: LocalContentRepository(),
          config: LocalConfigRepository(),
          prayer: LocalPrayerRepository(),
          device: LocalDeviceRepository(),
        );
      case DataSource.api:
        final api = ApiClient(baseUrl: Env.apiBaseUrl);
        return Repositories(
          schedule: ApiScheduleRepository(api),
          verse: ApiVerseRepository(api),
          content: ApiContentRepository(api),
          config: ApiConfigRepository(api),
          prayer: ApiPrayerRepository(api),
          device: ApiDeviceRepository(api),
        );
    }
  }
}

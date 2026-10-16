import '../models/app_config.dart';

abstract class ConfigRepository {
  Future<AppConfig> getConfig();
}

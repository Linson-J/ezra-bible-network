import '../../models/app_config.dart';
import '../config_repository.dart';
import 'asset_json.dart';

class LocalConfigRepository implements ConfigRepository {
  @override
  Future<AppConfig> getConfig() async =>
      AppConfig.fromJson(await loadAssetJson('app_config.json') as Map<String, dynamic>);
}

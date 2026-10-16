import '../../models/app_config.dart';
import '../config_repository.dart';
import 'api_client.dart';

/// GET /api/config -> AppConfig
class ApiConfigRepository implements ConfigRepository {
  ApiConfigRepository(this._api);
  final ApiClient _api;

  @override
  Future<AppConfig> getConfig() async =>
      AppConfig.fromJson(await _api.get('/api/config') as Map<String, dynamic>);
}

import '../../models/app_content.dart';
import '../content_repository.dart';
import 'api_client.dart';

/// GET /api/content -> AppContent
class ApiContentRepository implements ContentRepository {
  ApiContentRepository(this._api);
  final ApiClient _api;

  @override
  Future<AppContent> getContent() async =>
      AppContent.fromJson(await _api.get('/api/content') as Map<String, dynamic>);
}

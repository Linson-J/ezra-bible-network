import '../../models/app_content.dart';
import '../content_repository.dart';
import 'asset_json.dart';

class LocalContentRepository implements ContentRepository {
  @override
  Future<AppContent> getContent() async =>
      AppContent.fromJson(await loadAssetJson('app_content.json') as Map<String, dynamic>);
}

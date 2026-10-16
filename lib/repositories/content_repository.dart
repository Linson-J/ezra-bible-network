import '../models/app_content.dart';

abstract class ContentRepository {
  Future<AppContent> getContent();
}

import '../../models/verse.dart';
import '../verse_repository.dart';
import 'api_client.dart';

/// GET /api/verses?from=YYYY-MM-DD&days=30 -> [ { date, reference, text } ]
class ApiVerseRepository extends VerseRepository {
  ApiVerseRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<Verse>> getVerses({required DateTime from, int days = 30}) async {
    final list = await _api.get('/api/verses', query: {
      'from': Verse.formatDate(from),
      'days': '$days',
    }) as List<dynamic>;
    return list.map((e) => Verse.fromJson(e as Map<String, dynamic>)).toList();
  }
}

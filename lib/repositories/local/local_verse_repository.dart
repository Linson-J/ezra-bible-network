import '../../models/verse.dart';
import '../verse_repository.dart';
import 'asset_json.dart';

/// Picks verses from assets/data/verses.json by day of year.
class LocalVerseRepository extends VerseRepository {
  Map<int, Verse>? _byDay;

  Future<Map<int, Verse>> _load() async {
    if (_byDay != null) return _byDay!;
    final list = await loadAssetJson('verses.json') as List<dynamic>;
    final verses = list.map((e) => Verse.fromJson(e as Map<String, dynamic>));
    return _byDay = {for (final v in verses) v.day!: v};
  }

  @override
  Future<List<Verse>> getVerses({required DateTime from, int days = 30}) async {
    final byDay = await _load();
    if (byDay.isEmpty) return const [];
    return [
      for (var i = 0; i < days; i++)
        _pick(byDay, DateTime(from.year, from.month, from.day + i)),
    ];
  }

  Verse _pick(Map<int, Verse> byDay, DateTime date) {
    final doy = Verse.dayOfYear(date);
    // Fall back gracefully if the file has fewer than 366 entries.
    final verse = byDay[doy] ?? byDay[(doy - 1) % byDay.length + 1] ?? byDay.values.first;
    return verse.withDate(date);
  }
}

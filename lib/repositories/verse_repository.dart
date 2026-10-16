import '../models/verse.dart';

abstract class VerseRepository {
  /// Verses for [days] consecutive dates starting at [from] (local date).
  /// Each returned verse has [Verse.date] set.
  Future<List<Verse>> getVerses({required DateTime from, int days = 30});

  Future<Verse> getVerseFor(DateTime date) async {
    final list = await getVerses(from: date, days: 1);
    if (list.isEmpty) throw StateError('No verse available for $date');
    return list.first;
  }
}

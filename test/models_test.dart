import 'package:ezra_bible_network/models/app_config.dart';
import 'package:ezra_bible_network/models/program.dart';
import 'package:ezra_bible_network/models/verse.dart';
import 'package:ezra_bible_network/repositories/local/local_schedule_repository.dart';
import 'package:ezra_bible_network/repositories/local/local_verse_repository.dart';
import 'package:ezra_bible_network/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

Program prog(int day, String start, String end, [String id = 'p']) => Program(
      id: id, title: id, speaker: '', description: '',
      dayOfWeek: day, startTime: start, endTime: end,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Program', () {
    // 2026-10-12 is a Monday.
    final mon0900 = DateTime(2026, 10, 12, 9, 0);

    test('on air within its slot only', () {
      final p = prog(1, '09:00', '10:00');
      expect(p.isOnAirAt(mon0900), isTrue);
      expect(p.isOnAirAt(DateTime(2026, 10, 12, 9, 59)), isTrue);
      expect(p.isOnAirAt(DateTime(2026, 10, 12, 10, 0)), isFalse);
      expect(p.isOnAirAt(DateTime(2026, 10, 19, 9, 30)), isTrue); // next week
    });

    test('overnight program spans midnight, Sunday wraps to Monday', () {
      final sat = prog(6, '22:00', '05:30');
      expect(sat.durationMinutes, 450);
      expect(sat.isOnAirAt(DateTime(2026, 10, 18, 2, 0)), isTrue); // Sun 02:00
      final sun = prog(7, '21:00', '05:30');
      expect(sun.isOnAirAt(DateTime(2026, 10, 19, 5, 0)), isTrue); // Mon 05:00
      expect(sun.isOnAirAt(DateTime(2026, 10, 19, 5, 30)), isFalse);
    });

    test('minutesUntilStart wraps across the week', () {
      expect(prog(1, '10:00', '11:00').minutesUntilStart(mon0900), 60);
      expect(prog(1, '08:00', '09:00').minutesUntilStart(mon0900), 7 * 1440 - 60);
      expect(prog(1, '09:00', '10:00').minutesUntilStart(mon0900), 7 * 1440);
    });

    test('json round trip', () {
      final p = Program.fromJson(prog(3, '06:00', '07:00', 'x').toJson());
      expect(p.dayOfWeek, 3);
      expect(p.startTime, '06:00');
    });
  });

  group('Verse', () {
    test('dayOfYear', () {
      expect(Verse.dayOfYear(DateTime(2026, 1, 1)), 1);
      expect(Verse.dayOfYear(DateTime(2026, 12, 31)), 365);
      expect(Verse.dayOfYear(DateTime(2028, 12, 31)), 366);
    });

    test('local repo returns 30 dated verses and 366 distinct entries exist', () async {
      final repo = LocalVerseRepository();
      final list = await repo.getVerses(from: DateTime(2028, 12, 20), days: 30);
      expect(list, hasLength(30));
      expect(list.first.date, DateTime(2028, 12, 20));
      expect(list[11].day, 366); // 2028-12-31, leap year
      expect(list[12].day, 1); // 2029-01-01
      expect(list[12].date, DateTime(2029, 1, 1));

      final year = await repo.getVerses(from: DateTime(2028, 1, 1), days: 366);
      expect(year.map((v) => v.reference).toSet(), hasLength(366));
      expect(year.every((v) => v.text.isNotEmpty), isTrue);
    });
  });

  test('schedule asset covers every day with valid times', () async {
    final s = await LocalScheduleRepository().getSchedule();
    for (var d = 1; d <= 7; d++) {
      expect(s.where((p) => p.dayOfWeek == d), isNotEmpty, reason: 'day $d');
    }
    expect(s.map((p) => p.id).toSet(), hasLength(s.length));
    // Some program is on air at any minute of the week, and slots don't overlap.
    for (var m = 0; m < Program.minutesPerWeek; m += 15) {
      final t = DateTime(2026, 10, 12).add(Duration(minutes: m));
      expect(s.where((p) => p.isOnAirAt(t)), hasLength(1), reason: '$t');
    }
  });

  test('AppConfig.requiresUpdate', () {
    const c = AppConfig(minAppVersion: '1.2.0', forceUpdate: true);
    expect(c.requiresUpdate('1.1.9'), isTrue);
    expect(c.requiresUpdate('1.2.0'), isFalse);
    expect(c.requiresUpdate('1.10.0'), isFalse);
    expect(const AppConfig().requiresUpdate('0.0.1'), isFalse);
  });

  test('reminder ids are stable and in range', () {
    final a = NotificationService.reminderId('d1-03');
    expect(a, NotificationService.reminderId('d1-03'));
    expect(a, isNot(NotificationService.reminderId('d1-04')));
    expect(a, greaterThanOrEqualTo(100000));
    expect(a, lessThan(1100000));
  });
}

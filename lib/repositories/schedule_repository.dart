import '../models/program.dart';

abstract class ScheduleRepository {
  /// The full weekly schedule.
  Future<List<Program>> getSchedule();
}

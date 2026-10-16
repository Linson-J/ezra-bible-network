import '../../models/program.dart';
import '../schedule_repository.dart';
import 'asset_json.dart';

class LocalScheduleRepository implements ScheduleRepository {
  @override
  Future<List<Program>> getSchedule() async {
    final list = await loadAssetJson('schedule.json') as List<dynamic>;
    return list.map((e) => Program.fromJson(e as Map<String, dynamic>)).toList();
  }
}

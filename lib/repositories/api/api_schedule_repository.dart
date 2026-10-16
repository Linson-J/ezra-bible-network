import '../../models/program.dart';
import '../schedule_repository.dart';
import 'api_client.dart';

/// GET /api/schedule -> [ Program ]
class ApiScheduleRepository implements ScheduleRepository {
  ApiScheduleRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<Program>> getSchedule() async {
    final list = await _api.get('/api/schedule') as List<dynamic>;
    return list.map((e) => Program.fromJson(e as Map<String, dynamic>)).toList();
  }
}

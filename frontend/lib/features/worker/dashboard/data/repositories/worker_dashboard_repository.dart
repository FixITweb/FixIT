import '../models/worker_dashboard_model.dart';
import '../datasources/worker_dashboard_api.dart';

class WorkerDashboardRepository {
  final WorkerDashboardApi api;

  WorkerDashboardRepository(this.api);

  Future<WorkerDashboardModel> getDashboardStats() async {
    try {
      final data = await api.getDashboardStats();
      return WorkerDashboardModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load dashboard: $e');
    }
  }
}

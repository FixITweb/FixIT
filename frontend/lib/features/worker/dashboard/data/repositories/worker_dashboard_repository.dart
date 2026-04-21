import '../datasources/worker_dashboard_api.dart';
import '../models/worker_dashboard_model.dart';

class WorkerDashboardRepository {
  final WorkerDashboardApi api;

  WorkerDashboardRepository(this.api);

  Future<WorkerDashboardModel> getWorkerDashboard() async {
    return await api.getWorkerDashboard();
  }
}

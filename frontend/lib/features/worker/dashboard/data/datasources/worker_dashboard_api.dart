import '../models/worker_dashboard_model.dart';
import '../../../../../core/network/api_client.dart';

class WorkerDashboardApi {
  final ApiClient apiClient;

  WorkerDashboardApi(this.apiClient);

  Future<WorkerDashboardModel> getWorkerDashboard() async {
    try {
      final response = await apiClient.get(
        'auth/profile/',
        requireAuth: true,
      );
      return WorkerDashboardModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load worker dashboard: $e');
    }
  }
}

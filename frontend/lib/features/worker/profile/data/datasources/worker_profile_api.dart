import '../../../../../core/network/api_client.dart';
import '../models/worker_profile_model.dart';

class WorkerProfileApi {
  final ApiClient apiClient;

  WorkerProfileApi(this.apiClient);

  Future<WorkerProfileModel> getWorkerProfile() async {
    try {
      final response = await apiClient.get(
        'auth/profile/',
        requireAuth: true,
      );
      return WorkerProfileModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load worker profile: $e');
    }
  }
}

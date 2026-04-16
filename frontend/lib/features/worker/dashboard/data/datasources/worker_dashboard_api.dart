import '../../../../../core/network/api_client.dart';

class WorkerDashboardApi {
  final ApiClient client;

  WorkerDashboardApi(this.client);

  Future<Map<String, dynamic>> getDashboardStats() async {
    final res = await client.get('worker/dashboard/');
    return res.data;
  }
}
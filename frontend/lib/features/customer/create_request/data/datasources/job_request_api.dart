import '../../../../../core/network/api_client.dart';

class JobRequestApi {
  final ApiClient client;
  JobRequestApi(this.client);

  Future<Map<String, dynamic>> createJobRequest({
    required String title,
    required String description,
    required String category,
    double? budget,
  }) async {
    final response = await client.post('requests/', data: {
      'title': title,
      'description': description,
      'category': category,
      if (budget != null && budget > 0) 'budget': budget,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getJobRequests() async {
    final response = await client.get('requests/');
    return response.data as List<dynamic>;
  }
}

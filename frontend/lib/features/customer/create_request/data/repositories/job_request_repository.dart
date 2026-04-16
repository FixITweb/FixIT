import '../datasources/job_request_api.dart';

class JobRequestRepository {
  final JobRequestApi api;
  JobRequestRepository(this.api);

  Future<void> createJobRequest({
    required String title,
    required String description,
    required String category,
    double budget = 0.0,
  }) async {
    await api.createJobRequest(
      title: title,
      description: description,
      category: category,
      budget: budget,
    );
  }

  Future<List<dynamic>> getJobRequests() async {
    return await api.getJobRequests();
  }
}

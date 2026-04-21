import '../datasources/worker_profile_api.dart';
import '../models/worker_profile_model.dart';

class WorkerProfileRepository {
  final WorkerProfileApi api;

  WorkerProfileRepository(this.api);

  Future<WorkerProfileModel> getWorkerProfile() async {
    return await api.getWorkerProfile();
  }

  // Dashboard API removed: No backend endpoint exists for 'worker/dashboard/'.
}

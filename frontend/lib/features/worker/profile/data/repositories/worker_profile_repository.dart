import '../datasources/worker_profile_api.dart';
import '../../../dashboard/data/datasources/worker_dashboard_api.dart';
import '../models/worker_profile_model.dart';

class WorkerProfileRepository {
  final WorkerProfileApi profileApi;
  final WorkerDashboardApi dashboardApi;

  WorkerProfileRepository(this.profileApi, this.dashboardApi);

  Future<WorkerProfileModel> getWorkerProfile() async {
    final profile = await profileApi.getWorkerProfile();
    final dashboard = await dashboardApi.getWorkerDashboard();

    return WorkerProfileModel(
      id: profile.id,
      username: profile.username,
      email: profile.email,
      role: profile.role,
      createdAt: profile.createdAt,

      // 🔥 FROM DASHBOARD MODEL (NOT MAP)
      servicesCount: dashboard.servicesCount,
      bookingsCount: dashboard.bookingsCount,
      completedJobs: dashboard.completedJobs,
      totalEarnings: dashboard.totalEarnings,
      averageRating: dashboard.averageRating,
    );
  }
}

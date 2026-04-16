class WorkerDashboardData {
  final double totalEarnings;
  final int activeBookings;
  final int completedJobs;
  final double rating;
  final String username;

  WorkerDashboardData({
    required this.totalEarnings,
    required this.activeBookings,
    required this.completedJobs,
    required this.rating,
    required this.username,
  });
}

abstract class WorkerDashboardState {}

class WorkerDashboardInitial extends WorkerDashboardState {}

class WorkerDashboardLoading extends WorkerDashboardState {}

class WorkerDashboardLoaded extends WorkerDashboardState {
  final WorkerDashboardData data;
  WorkerDashboardLoaded(this.data);
}

class WorkerDashboardError extends WorkerDashboardState {
  final String message;
  WorkerDashboardError(this.message);
}
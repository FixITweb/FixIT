abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final double totalEarnings;
  final int activeBookings;
  final int completedJobs;
  final double rating;

  DashboardLoaded({
    required this.totalEarnings,
    required this.activeBookings,
    required this.completedJobs,
    required this.rating,
  });
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
import '../../data/models/worker_dashboard_model.dart';

abstract class WorkerDashboardState {
  const WorkerDashboardState();
}

class WorkerDashboardInitial extends WorkerDashboardState {
  const WorkerDashboardInitial();
}

class WorkerDashboardLoading extends WorkerDashboardState {
  const WorkerDashboardLoading();
}

class WorkerDashboardLoaded extends WorkerDashboardState {
  final WorkerDashboardModel dashboard;

  const WorkerDashboardLoaded({required this.dashboard});
}

class WorkerDashboardError extends WorkerDashboardState {
  final String message;

  const WorkerDashboardError({required this.message});
}

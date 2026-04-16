import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_dashboard_event.dart';
import 'worker_dashboard_state.dart';
import '../../data/repositories/worker_dashboard_repository.dart';

class WorkerDashboardBloc extends Bloc<WorkerDashboardEvent, WorkerDashboardState> {
  final WorkerDashboardRepository repository;

  WorkerDashboardBloc(this.repository) : super(WorkerDashboardInitial()) {
    on<LoadWorkerDashboard>((event, emit) async {
      emit(WorkerDashboardLoading());
      try {
        // Load real dashboard data from API
        final dashboardData = await repository.getDashboardStats();
        
        final data = WorkerDashboardData(
          totalEarnings: dashboardData.totalEarnings,
          activeBookings: dashboardData.activeBookings,
          completedJobs: dashboardData.completedJobs,
          rating: dashboardData.rating,
          username: dashboardData.username,
        );
        
        emit(WorkerDashboardLoaded(data));
      } catch (e) {
        emit(WorkerDashboardError('Failed to load dashboard: ${e.toString()}'));
      }
    });

    on<RefreshDashboard>((event, emit) async {
      if (state is WorkerDashboardLoaded) {
        emit(WorkerDashboardLoading());
        add(LoadWorkerDashboard());
      }
    });
  }
}
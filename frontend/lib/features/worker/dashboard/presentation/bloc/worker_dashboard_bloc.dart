import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_dashboard_event.dart';
import 'worker_dashboard_state.dart';

class WorkerDashboardBloc extends Bloc<WorkerDashboardEvent, WorkerDashboardState> {
  WorkerDashboardBloc() : super(WorkerDashboardInitial()) {
    on<LoadWorkerDashboard>((event, emit) async {
      emit(WorkerDashboardLoading());
      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Mock data - replace with actual API call
        final data = WorkerDashboardData(
          totalEarnings: 2450.0,
          activeBookings: 8,
          completedJobs: 45,
          rating: 4.8,
        );
        
        emit(WorkerDashboardLoaded(data));
      } catch (e) {
        emit(WorkerDashboardError(e.toString()));
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
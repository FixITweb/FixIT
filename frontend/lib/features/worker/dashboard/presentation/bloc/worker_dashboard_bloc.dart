import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/worker_dashboard_repository.dart';
import 'worker_dashboard_event.dart';
import 'worker_dashboard_state.dart';

class WorkerDashboardBloc extends Bloc<WorkerDashboardEvent, WorkerDashboardState> {
  final WorkerDashboardRepository repository;

  WorkerDashboardBloc(this.repository) : super(const WorkerDashboardInitial()) {
    on<LoadWorkerDashboard>(_onLoadWorkerDashboard);
    on<RefreshWorkerDashboard>(_onRefreshWorkerDashboard);
  }

  Future<void> _onLoadWorkerDashboard(
    LoadWorkerDashboard event,
    Emitter<WorkerDashboardState> emit,
  ) async {
    emit(const WorkerDashboardLoading());
    try {
      final dashboard = await repository.getWorkerDashboard();
      emit(WorkerDashboardLoaded(dashboard: dashboard));
    } catch (e) {
      emit(WorkerDashboardError(message: e.toString()));
    }
  }

  Future<void> _onRefreshWorkerDashboard(
    RefreshWorkerDashboard event,
    Emitter<WorkerDashboardState> emit,
  ) async {
    try {
      final dashboard = await repository.getWorkerDashboard();
      emit(WorkerDashboardLoaded(dashboard: dashboard));
    } catch (e) {
      emit(WorkerDashboardError(message: e.toString()));
    }
  }
}

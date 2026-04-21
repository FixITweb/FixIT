import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/worker_profile_repository.dart';
import 'worker_profile_event.dart';
import 'worker_profile_state.dart';

class WorkerProfileBloc extends Bloc<WorkerProfileEvent, WorkerProfileState> {
  final WorkerProfileRepository repository;

  WorkerProfileBloc(this.repository) : super(WorkerProfileInitial()) {
    on<LoadWorkerProfile>(_onLoadWorkerProfile);
    on<RefreshWorkerProfile>(_onRefreshWorkerProfile);
  }

  Future<void> _onLoadWorkerProfile(
    LoadWorkerProfile event,
    Emitter<WorkerProfileState> emit,
  ) async {
    emit(WorkerProfileLoading());
    try {
      final profile = await repository.getWorkerProfile();
      emit(WorkerProfileLoaded(profile: profile));
    } catch (e) {
      emit(WorkerProfileError(message: e.toString()));
    }
  }

  Future<void> _onRefreshWorkerProfile(
    RefreshWorkerProfile event,
    Emitter<WorkerProfileState> emit,
  ) async {
    try {
      final profile = await repository.getWorkerProfile();
      emit(WorkerProfileLoaded(profile: profile));
    } catch (e) {
      emit(WorkerProfileError(message: e.toString()));
    }
  }
}

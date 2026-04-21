import '../../data/models/worker_profile_model.dart';

abstract class WorkerProfileState {}

class WorkerProfileInitial extends WorkerProfileState {}

class WorkerProfileLoading extends WorkerProfileState {}

class WorkerProfileLoaded extends WorkerProfileState {
  final WorkerProfileModel profile;

  WorkerProfileLoaded({required this.profile});
}

class WorkerProfileError extends WorkerProfileState {
  final String message;

  WorkerProfileError({required this.message});
}

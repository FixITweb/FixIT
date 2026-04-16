import '../../../../services/data/models/service_model.dart';

abstract class WorkerServicesState {}

class WorkerServicesInitial extends WorkerServicesState {}

class WorkerServicesLoading extends WorkerServicesState {}

class WorkerServicesLoaded extends WorkerServicesState {
  final List<ServiceModel> services;
  WorkerServicesLoaded(this.services);
}

class WorkerServiceAdded extends WorkerServicesState {
  final String message;
  WorkerServiceAdded(this.message);
}

class WorkerServiceUpdated extends WorkerServicesState {
  final String message;
  WorkerServiceUpdated(this.message);
}

class WorkerServiceDeleted extends WorkerServicesState {
  final String message;
  WorkerServiceDeleted(this.message);
}

class WorkerServicesError extends WorkerServicesState {
  final String message;
  WorkerServicesError(this.message);
}

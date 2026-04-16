import '../../../../services/data/models/service_model.dart';

abstract class ServiceDetailState {}

class ServiceDetailInitial extends ServiceDetailState {}

class ServiceDetailLoading extends ServiceDetailState {}

class ServiceDetailLoaded extends ServiceDetailState {
  final ServiceModel service;

  ServiceDetailLoaded(this.service);
}

class ServiceDetailError extends ServiceDetailState {
  final String message;

  ServiceDetailError(this.message);
}

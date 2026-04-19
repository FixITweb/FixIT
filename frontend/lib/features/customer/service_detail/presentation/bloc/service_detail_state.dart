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

// Booking States - Now including the ServiceModel to maintain UI state
class BookingInProgress extends ServiceDetailState {
  final ServiceModel service;
  BookingInProgress(this.service);
}

class BookingSuccess extends ServiceDetailState {
  final ServiceModel service;
  BookingSuccess(this.service);
}

class BookingError extends ServiceDetailState {
  final String message;
  final ServiceModel service;
  BookingError(this.message, this.service);
}

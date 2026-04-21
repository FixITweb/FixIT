import '../../data/models/worker_booking_model.dart';

abstract class WorkerBookingsState {}

class WorkerBookingsInitial extends WorkerBookingsState {}

class WorkerBookingsLoading extends WorkerBookingsState {}

class WorkerBookingsLoaded extends WorkerBookingsState {
  final List<WorkerBookingModel> bookings;
  WorkerBookingsLoaded(this.bookings);
}

class WorkerBookingUpdated extends WorkerBookingsState {
  final String message;
  WorkerBookingUpdated(this.message);
}

class WorkerBookingsError extends WorkerBookingsState {
  final String message;
  WorkerBookingsError(this.message);
}
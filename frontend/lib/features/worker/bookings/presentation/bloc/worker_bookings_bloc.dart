import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_bookings_event.dart';
import 'worker_bookings_state.dart';
import '../../data/repositories/worker_bookings_repository.dart';
import '../../data/models/worker_booking_model.dart';

class WorkerBookingsBloc extends Bloc<WorkerBookingsEvent, WorkerBookingsState> {
  final WorkerBookingsRepository repository;

  WorkerBookingsBloc(this.repository) : super(WorkerBookingsInitial()) {
    on<LoadWorkerBookings>((event, emit) async {
      emit(WorkerBookingsLoading());
      try {
        final bookings = await repository.getWorkerBookings();
        emit(WorkerBookingsLoaded(bookings));
      } catch (e) {
        emit(WorkerBookingsError('Failed to load bookings: ${e.toString()}'));
      }
    });

    on<AcceptBooking>((event, emit) async {
      try {
        await repository.acceptBooking(event.bookingId);
        emit(WorkerBookingUpdated('Booking accepted successfully!'));
        add(LoadWorkerBookings());
      } catch (e) {
        emit(WorkerBookingsError('Failed to accept booking: ${e.toString()}'));
      }
    });

    on<RejectBooking>((event, emit) async {
      try {
        await repository.rejectBooking(event.bookingId);
        emit(WorkerBookingUpdated('Booking rejected'));
        add(LoadWorkerBookings());
      } catch (e) {
        emit(WorkerBookingsError('Failed to reject booking: ${e.toString()}'));
      }
    });

    on<CompleteBooking>((event, emit) async {
      try {
        await repository.completeBooking(event.bookingId);
        emit(WorkerBookingUpdated('Booking marked as completed!'));
        add(LoadWorkerBookings());
      } catch (e) {
        emit(WorkerBookingsError('Failed to complete booking: ${e.toString()}'));
      }
    });
  }
}
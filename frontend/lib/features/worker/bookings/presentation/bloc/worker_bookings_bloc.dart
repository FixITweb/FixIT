import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_bookings_event.dart';
import 'worker_bookings_state.dart';
import '../../../../bookings/data/repositories/booking_repository.dart';

class WorkerBookingsBloc extends Bloc<WorkerBookingsEvent, WorkerBookingsState> {
  final BookingRepository bookingRepository;

  WorkerBookingsBloc(this.bookingRepository) : super(WorkerBookingsInitial()) {
    on<LoadWorkerBookings>((event, emit) async {
      emit(WorkerBookingsLoading());
      try {
        // Load real bookings from API
        final bookings = await bookingRepository.getBookings();
        
        // Convert to worker booking models
        final workerBookings = bookings.map((booking) => WorkerBookingModel(
          id: booking.id.toString(),
          serviceTitle: booking.service?.title ?? 'Unknown Service',
          customerName: booking.customer?.username ?? 'Unknown Customer',
          scheduledDate: booking.createdAt,
          status: _capitalizeStatus(booking.status),
          price: booking.service?.price ?? 0.0,
        )).toList();
        
        emit(WorkerBookingsLoaded(workerBookings));
      } catch (e) {
        emit(WorkerBookingsError('Failed to load bookings: ${e.toString()}'));
      }
    });

    on<AcceptBooking>((event, emit) async {
      try {
        await bookingRepository.updateBooking(int.parse(event.bookingId), 'accepted');
        emit(WorkerBookingUpdated('Booking accepted successfully!'));
        add(LoadWorkerBookings()); // Reload bookings
      } catch (e) {
        emit(WorkerBookingsError('Failed to accept booking: ${e.toString()}'));
      }
    });

    on<RejectBooking>((event, emit) async {
      try {
        await bookingRepository.updateBooking(int.parse(event.bookingId), 'rejected');
        emit(WorkerBookingUpdated('Booking rejected'));
        add(LoadWorkerBookings()); // Reload bookings
      } catch (e) {
        emit(WorkerBookingsError('Failed to reject booking: ${e.toString()}'));
      }
    });

    on<CompleteBooking>((event, emit) async {
      try {
        await bookingRepository.updateBooking(int.parse(event.bookingId), 'completed');
        emit(WorkerBookingUpdated('Booking marked as completed!'));
        add(LoadWorkerBookings()); // Reload bookings
      } catch (e) {
        emit(WorkerBookingsError('Failed to complete booking: ${e.toString()}'));
      }
    });
  }

  String _capitalizeStatus(String status) {
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_bookings_event.dart';
import 'worker_bookings_state.dart';

class WorkerBookingsBloc extends Bloc<WorkerBookingsEvent, WorkerBookingsState> {
  List<WorkerBookingModel> _bookings = [];

  WorkerBookingsBloc() : super(WorkerBookingsInitial()) {
    on<LoadWorkerBookings>((event, emit) async {
      emit(WorkerBookingsLoading());
      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Mock data - replace with actual API call
        _bookings = [
          WorkerBookingModel(
            id: '1',
            serviceTitle: 'Kitchen Sink Repair',
            customerName: 'Sarah Johnson',
            scheduledDate: DateTime.now().add(const Duration(days: 1)),
            status: 'Pending',
            price: 75.0,
          ),
          WorkerBookingModel(
            id: '2',
            serviceTitle: 'Bathroom Installation',
            customerName: 'Mike Chen',
            scheduledDate: DateTime.now().add(const Duration(days: 3)),
            status: 'Accepted',
            price: 150.0,
          ),
        ];
        
        emit(WorkerBookingsLoaded(_bookings));
      } catch (e) {
        emit(WorkerBookingsError(e.toString()));
      }
    });

    on<AcceptBooking>((event, emit) async {
      try {
        final bookingIndex = _bookings.indexWhere((b) => b.id == event.bookingId);
        if (bookingIndex != -1) {
          _bookings[bookingIndex] = _bookings[bookingIndex].copyWith(status: 'Accepted');
          emit(WorkerBookingUpdated('Booking accepted successfully!'));
          emit(WorkerBookingsLoaded(_bookings));
        }
      } catch (e) {
        emit(WorkerBookingsError(e.toString()));
      }
    });

    on<RejectBooking>((event, emit) async {
      try {
        final bookingIndex = _bookings.indexWhere((b) => b.id == event.bookingId);
        if (bookingIndex != -1) {
          _bookings[bookingIndex] = _bookings[bookingIndex].copyWith(status: 'Rejected');
          emit(WorkerBookingUpdated('Booking rejected'));
          emit(WorkerBookingsLoaded(_bookings));
        }
      } catch (e) {
        emit(WorkerBookingsError(e.toString()));
      }
    });

    on<CompleteBooking>((event, emit) async {
      try {
        final bookingIndex = _bookings.indexWhere((b) => b.id == event.bookingId);
        if (bookingIndex != -1) {
          _bookings[bookingIndex] = _bookings[bookingIndex].copyWith(status: 'Completed');
          emit(WorkerBookingUpdated('Booking marked as completed!'));
          emit(WorkerBookingsLoaded(_bookings));
        }
      } catch (e) {
        emit(WorkerBookingsError(e.toString()));
      }
    });
  }
}
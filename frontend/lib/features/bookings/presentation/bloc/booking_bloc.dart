import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_event.dart';
import 'booking_state.dart';
import '../../data/repositories/booking_repository.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository repo;

  BookingBloc(this.repo) : super(BookingInitial()) {
    on<LoadBookings>((event, emit) async {
      emit(BookingLoading());
      try {
        // Use real API instead of mock data
        final bookings = await repo.getBookings();
        emit(BookingLoaded(bookings));
      } catch (e) {
        emit(BookingError('Failed to load bookings: ${e.toString()}'));
      }
    });

    on<CreateBooking>((event, emit) async {
      emit(BookingLoading());
      try {
        final success = await repo.createBooking(event.serviceId);
        if (success) {
          emit(BookingCreated());
          add(LoadBookings()); // Refresh the list
        } else {
          emit(BookingError('Failed to create booking'));
        }
      } catch (e) {
        emit(BookingError('Failed to create booking: ${e.toString()}'));
      }
    });

    on<UpdateBooking>((event, emit) async {
      emit(BookingLoading());
      try {
        final booking = await repo.updateBooking(event.bookingId, event.status);
        emit(BookingUpdated(booking));
      } catch (e) {
        emit(BookingError('Failed to update booking: ${e.toString()}'));
      }
    });

    //new
    on<DeleteBooking>((event, emit) async {
  try {
    final success = await repo.deleteBooking(event.bookingId);

    if (success) {
      add(LoadBookings()); 
    } else {
      emit(BookingError("Failed to delete booking"));
    }
  } catch (e) {
    emit(BookingError(e.toString()));
  }
});
  }
}
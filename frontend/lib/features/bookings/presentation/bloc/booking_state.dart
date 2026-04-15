import '../../data/models/booking_model.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<BookingModel> bookings;
  BookingLoaded(this.bookings);
}

class BookingCreated extends BookingState {
  final BookingModel booking;
  BookingCreated(this.booking);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}
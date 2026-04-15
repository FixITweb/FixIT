import '../../data/models/booking_model.dart';

abstract class BookingEvent {}

class LoadBookings extends BookingEvent {}

class CreateBooking extends BookingEvent {
  final BookingModel booking;
  CreateBooking(this.booking);
}
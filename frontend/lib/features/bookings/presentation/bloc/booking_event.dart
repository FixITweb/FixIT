abstract class BookingEvent {}

class LoadBookings extends BookingEvent {}

class CreateBooking extends BookingEvent {
  final int serviceId;
  CreateBooking(this.serviceId);
}

class UpdateBooking extends BookingEvent {
  final int bookingId;
  final String status;
  UpdateBooking(this.bookingId, this.status);
}

//new
class DeleteBooking extends BookingEvent {
  final int bookingId;

  DeleteBooking(this.bookingId);
}
abstract class WorkerBookingsEvent {}

class LoadWorkerBookings extends WorkerBookingsEvent {}

class AcceptBooking extends WorkerBookingsEvent {
  final String bookingId;
  AcceptBooking(this.bookingId);
}

class RejectBooking extends WorkerBookingsEvent {
  final String bookingId;
  RejectBooking(this.bookingId);
}

class CompleteBooking extends WorkerBookingsEvent {
  final String bookingId;
  CompleteBooking(this.bookingId);
}
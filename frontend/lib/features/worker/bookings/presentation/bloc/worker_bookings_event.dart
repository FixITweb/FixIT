abstract class WorkerBookingsEvent {}

class LoadWorkerBookings extends WorkerBookingsEvent {}

class AcceptBooking extends WorkerBookingsEvent {
  final int bookingId;
  AcceptBooking(this.bookingId);
}

class RejectBooking extends WorkerBookingsEvent {
  final int bookingId;
  RejectBooking(this.bookingId);
}

class CompleteBooking extends WorkerBookingsEvent {
  final int bookingId;
  CompleteBooking(this.bookingId);
}
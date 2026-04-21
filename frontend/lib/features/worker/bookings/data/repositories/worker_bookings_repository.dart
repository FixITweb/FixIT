import '../datasources/worker_bookings_api.dart';
import '../models/worker_booking_model.dart';

class WorkerBookingsRepository {
  final WorkerBookingsApi api;

  WorkerBookingsRepository(this.api);

  Future<List<WorkerBookingModel>> getWorkerBookings() async {
    return await api.getWorkerBookings();
  }

  Future<Map<String, dynamic>> acceptBooking(int bookingId) async {
    return await api.acceptBooking(bookingId);
  }

  Future<Map<String, dynamic>> rejectBooking(int bookingId) async {
    return await api.rejectBooking(bookingId);
  }

  Future<Map<String, dynamic>> completeBooking(int bookingId) async {
    return await api.completeBooking(bookingId);
  }
}

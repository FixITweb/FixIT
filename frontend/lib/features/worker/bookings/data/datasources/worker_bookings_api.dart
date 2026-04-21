import '../models/worker_booking_model.dart';
import '../../../../../core/network/api_client.dart';

class WorkerBookingsApi {
  final ApiClient apiClient;

  WorkerBookingsApi(this.apiClient);

  Future<List<WorkerBookingModel>> getWorkerBookings() async {
    try {
      final response = await apiClient.get(
        'bookings/',
        requireAuth: true,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => WorkerBookingModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load worker bookings: $e');
    }
  }

  Future<Map<String, dynamic>> updateBookingStatus({
    required int bookingId,
    required String status,
  }) async {
    try {
      final response = await apiClient.put(
        'bookings/$bookingId/',
        data: {'status': status},
        requireAuth: true,
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  Future<Map<String, dynamic>> acceptBooking(int bookingId) async {
    return updateBookingStatus(bookingId: bookingId, status: 'accepted');
  }

  Future<Map<String, dynamic>> rejectBooking(int bookingId) async {
    return updateBookingStatus(bookingId: bookingId, status: 'rejected');
  }

  Future<Map<String, dynamic>> completeBooking(int bookingId) async {
    return updateBookingStatus(bookingId: bookingId, status: 'completed');
  }
}

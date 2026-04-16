import '../../../../core/network/api_client.dart';

class BookingApi {
  final ApiClient client;

  BookingApi(this.client);

  // GET bookings — backend endpoint: GET /api/bookings/
  Future<List<dynamic>> fetchBookings() async {
    final res = await client.get('bookings/');
    return res.data as List<dynamic>;
  }

  // POST create booking — backend endpoint: POST /api/bookings/create/
  Future<Map<String, dynamic>> createBooking(int serviceId) async {
    final res = await client.post('bookings/create/', data: {
      'service_id': serviceId,
    });
    return res.data as Map<String, dynamic>;
  }

  // PUT update booking status — backend endpoint: PUT /api/bookings/<id>/
  Future<Map<String, dynamic>> updateBooking(int bookingId, String status) async {
    final res = await client.put('bookings/$bookingId/', data: {
      'status': status,
    });
    return res.data as Map<String, dynamic>;
  }
}

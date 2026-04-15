import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

class BookingApi {
  final ApiClient client;

  BookingApi(this.client);

  Future<List<dynamic>> fetchBookings() async {
    final res = await client.get(Endpoints.bookings);
    return res.data;
  }

  Future<Map<String, dynamic>> createBooking(int serviceId) async {
    final res = await client.post(Endpoints.createBooking, data: {
      'service_id': serviceId,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> updateBooking(int bookingId, String status) async {
    final res = await client.put('${Endpoints.bookings}$bookingId/', data: {
      'status': status,
    });
    return res.data;
  }
}
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

class BookingApi {
  final ApiClient client;

  BookingApi(this.client);

  Future<List<dynamic>> fetchBookings() async {
    final res = await client.get(Endpoints.bookings);
    return res.data;
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    final res = await client.post(Endpoints.bookings, data: bookingData);
    return res.data;
  }
}
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

class BookingApi {
  final ApiClient client;

  BookingApi(this.client);

  // GET bookings — backend endpoint: GET /api/bookings/
  Future<List<dynamic>> fetchBookings() async {
    final res = await client.get(Endpoints.bookings);

    //new
    print("==== BOOKINGS API RESPONSE ===="); 
    print("🔥 RAW BOOKINGS RESPONSE:");
    print(res.data);

    for (var b in res.data) {
      print("📦 booking item: $b");
    } 

    return (res.data as List)
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
  }

  // POST create booking — backend endpoint: POST /api/bookings/
  Future<void> createBooking(int serviceId) async {
    try {
      await client.post(Endpoints.bookings, data: {
        'service_id': serviceId,
      });
      // Documentation shows no response body, so we just return on success.
    } catch (e) {
      rethrow;
    }
  }

  // PUT update booking status — backend endpoint: PUT /api/bookings/<id>/
  Future<Map<String, dynamic>> updateBooking(int bookingId, String status) async {
    final res = await client.put('${Endpoints.bookings}$bookingId/', data: {
      'status': status,
    });
    return res.data as Map<String, dynamic>;
  }

  //new
  Future<void> deleteBooking(int id) async {
  await client.delete('${Endpoints.deleteBooking}$id/');
}
}

import '../models/booking_model.dart';
import '../datasources/booking_api.dart';

class BookingRepository {
  final BookingApi api;

  BookingRepository(this.api);

  Future<List<BookingModel>> getBookings() async {
    final data = await api.fetchBookings();
    return data.map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<bool> createBooking(int serviceId) async {
    try {
      await api.createBooking(serviceId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<BookingModel> updateBooking(int bookingId, String status) async {
    final data = await api.updateBooking(bookingId, status);
    return BookingModel.fromJson(data);
  }
}
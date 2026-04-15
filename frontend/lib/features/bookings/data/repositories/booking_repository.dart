import '../models/booking_model.dart';
import '../datasources/booking_api.dart';

class BookingRepository {
  final BookingApi api;

  BookingRepository(this.api);

  Future<List<BookingModel>> getBookings() async {
    final data = await api.fetchBookings();
    return data.map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<BookingModel> createBooking(int serviceId) async {
    final data = await api.createBooking(serviceId);
    return BookingModel.fromJson(data);
  }

  Future<BookingModel> updateBooking(int bookingId, String status) async {
    final data = await api.updateBooking(bookingId, status);
    return BookingModel.fromJson(data);
  }
}
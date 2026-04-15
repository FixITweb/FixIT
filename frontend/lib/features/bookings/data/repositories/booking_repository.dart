import '../models/booking_model.dart';
import '../datasources/booking_api.dart';

class BookingRepository {
  final BookingApi api;

  BookingRepository(this.api);

  Future<List<BookingModel>> getBookings() async {
    final data = await api.fetchBookings();
    return data.map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    final data = await api.createBooking(booking.toJson());
    return BookingModel.fromJson(data);
  }
}
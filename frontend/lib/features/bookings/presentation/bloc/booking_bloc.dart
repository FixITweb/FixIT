import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_event.dart';
import 'booking_state.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/booking_model.dart';
import '../../../../../shared/data/mock_data.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository repo;

  BookingBloc(this.repo) : super(BookingInitial()) {
    on<LoadBookings>((event, emit) async {
      emit(BookingLoading());
      try {
        // For now, use mock data - later replace with repo.getBookings()
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Convert mock bookings to real booking models
        final bookings = mockBookings.map((mock) => BookingModel(
          id: mock.id,
          serviceId: '1', // Default service ID
          userId: '1', // Default user ID
          providerId: '1', // Default provider ID
          scheduledDate: mock.scheduledDate,
          status: mock.status,
          totalPrice: mock.price,
          notes: mock.serviceTitle,
        )).toList();
        
        emit(BookingLoaded(bookings));
      } catch (e) {
        emit(BookingError(e.toString()));
      }
    });

    on<CreateBooking>((event, emit) async {
      emit(BookingLoading());
      try {
        final booking = await repo.createBooking(event.booking);
        emit(BookingCreated(booking));
      } catch (e) {
        emit(BookingError(e.toString()));
      }
    });
  }
}
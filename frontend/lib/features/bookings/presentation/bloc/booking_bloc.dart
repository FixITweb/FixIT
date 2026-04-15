import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_event.dart';
import 'booking_state.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/booking_model.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository repo;

  BookingBloc(this.repo) : super(BookingInitial()) {
    on<LoadBookings>((event, emit) async {
      emit(BookingLoading());
      try {
        // For demo purposes, use mock data
        await Future.delayed(const Duration(milliseconds: 500));
        
        final mockBookings = [
          BookingModel(
            id: 1,
            service: ServiceInfo(
              id: 1,
              title: 'Sink Repair',
              description: 'Professional sink repair service',
              category: 'Plumbing',
              price: 75.0,
              worker: WorkerInfo(id: 1, username: 'John Smith'),
            ),
            status: 'pending',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          BookingModel(
            id: 2,
            service: ServiceInfo(
              id: 2,
              title: 'House Cleaning',
              description: 'Complete house cleaning service',
              category: 'Cleaning',
              price: 120.0,
              worker: WorkerInfo(id: 2, username: 'Sarah Johnson'),
            ),
            status: 'accepted',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ];
        
        emit(BookingLoaded(mockBookings));
      } catch (e) {
        emit(BookingError(e.toString()));
      }
    });

    on<CreateBooking>((event, emit) async {
      emit(BookingLoading());
      try {
        // For demo purposes, create a mock booking
        await Future.delayed(const Duration(milliseconds: 500));
        
        final newBooking = BookingModel(
          id: DateTime.now().millisecondsSinceEpoch,
          service: ServiceInfo(
            id: event.serviceId,
            title: 'New Service',
            description: 'Service description',
            category: 'General',
            price: 50.0,
            worker: WorkerInfo(id: 1, username: 'Worker'),
          ),
          status: 'pending',
          createdAt: DateTime.now(),
        );
        
        emit(BookingCreated(newBooking));
      } catch (e) {
        emit(BookingError(e.toString()));
      }
    });

    on<UpdateBooking>((event, emit) async {
      emit(BookingLoading());
      try {
        // For demo purposes, create a mock updated booking
        await Future.delayed(const Duration(milliseconds: 500));
        
        final updatedBooking = BookingModel(
          id: event.bookingId,
          service: ServiceInfo(
            id: 1,
            title: 'Updated Service',
            description: 'Updated service description',
            category: 'General',
            price: 75.0,
            worker: WorkerInfo(id: 1, username: 'Worker'),
          ),
          status: event.status,
          createdAt: DateTime.now(),
        );
        
        emit(BookingUpdated(updatedBooking));
      } catch (e) {
        emit(BookingError(e.toString()));
      }
    });
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'service_detail_event.dart';
import 'service_detail_state.dart';
import '../../../../services/data/repositories/services_repository.dart';
import '../../../../bookings/data/repositories/booking_repository.dart';

class ServiceDetailBloc extends Bloc<ServiceDetailEvent, ServiceDetailState> {
  final ServiceRepository repository;
  final BookingRepository bookingRepository;

  ServiceDetailBloc({
    required this.repository,
    required this.bookingRepository,
  }) : super(ServiceDetailInitial()) {
    
    on<LoadServiceDetail>((event, emit) async {
      emit(ServiceDetailLoading());
      try {
        final services = await repository.getServices();
        final service = services.firstWhere(
          (s) => s.id.toString() == event.serviceId,
          orElse: () => services.first,
        );
        emit(ServiceDetailLoaded(service));
      } catch (e) {
        emit(ServiceDetailError('Failed to load service: ${e.toString()}'));
      }
    });

    on<BookService>((event, emit) async {
      final currentState = state;
      if (currentState is! ServiceDetailLoaded) return;
      
      final service = currentState.service;
      emit(BookingInProgress(service));
      
      try {
        final success = await bookingRepository.createBooking(event.serviceId);
        if (success) {
          emit(BookingSuccess(service));
        } else {
          emit(BookingError('Could not process booking. Please try again.', service));
          emit(ServiceDetailLoaded(service));
        }
      } catch (e) {
        emit(BookingError('Booking failed: ${e.toString()}', service));
        emit(ServiceDetailLoaded(service));
      }
    });
  }
}

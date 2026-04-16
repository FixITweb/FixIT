import 'package:flutter_bloc/flutter_bloc.dart';
import 'service_detail_event.dart';
import 'service_detail_state.dart';
import '../../../../services/data/repositories/services_repository.dart';

class ServiceDetailBloc extends Bloc<ServiceDetailEvent, ServiceDetailState> {
  final ServiceRepository repository;

  ServiceDetailBloc(this.repository) : super(ServiceDetailInitial()) {
    on<LoadServiceDetail>((event, emit) async {
      emit(ServiceDetailLoading());
      try {
        // Get all services and find the one with matching ID
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
  }
}

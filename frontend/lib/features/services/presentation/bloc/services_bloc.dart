import 'package:flutter_bloc/flutter_bloc.dart';
import 'services_event.dart';
import 'services_state.dart';
import '../../data/repositories/services_repository.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceRepository repo;

  ServiceBloc(this.repo) : super(ServiceInitial()) {
    on<LoadServices>((event, emit) async {
      emit(ServiceLoading());
      try {
        final data = await repo.getServices();
        emit(ServiceLoaded(data));
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });
  }
}
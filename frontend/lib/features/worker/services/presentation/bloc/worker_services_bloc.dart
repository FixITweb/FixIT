import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_services_event.dart';
import 'worker_services_state.dart';
import '../../../../services/data/repositories/services_repository.dart';
import '../../../../services/data/models/service_model.dart';

class WorkerServicesBloc extends Bloc<WorkerServicesEvent, WorkerServicesState> {
  final ServiceRepository serviceRepository;
  List<ServiceModel> _services = [];

  WorkerServicesBloc(this.serviceRepository) : super(WorkerServicesInitial()) {
    on<LoadWorkerServices>(_onLoad);
    on<AddWorkerService>(_onAdd);
    on<UpdateWorkerService>(_onUpdate);
    on<DeleteWorkerService>(_onDelete);
  }

  Future<void> _onLoad(LoadWorkerServices event, Emitter emit) async {
    emit(WorkerServicesLoading());
    try {
      final services = await serviceRepository.getMyServices();
      _services = services;
      emit(WorkerServicesLoaded(_services));
    } catch (e) {
      emit(WorkerServicesError('Failed to load services: $e'));
    }
  }

  Future<void> _onAdd(AddWorkerService event, Emitter emit) async {
    emit(WorkerServicesLoading());
    try {
      await serviceRepository.createService(
        title: event.title,
        description: event.description,
        category: event.category,
        price: event.price,
        latitude: 0.0,
        longitude: 0.0,
      );
      emit(WorkerServiceAdded('Service added successfully!'));
      final services = await serviceRepository.getMyServices();
      _services = services;
      emit(WorkerServicesLoaded(_services));
    } catch (e) {
      emit(WorkerServicesError('Failed to add service: $e'));
    }
  }

  Future<void> _onUpdate(UpdateWorkerService event, Emitter emit) async {
    emit(WorkerServicesLoading());
    try {
      await serviceRepository.updateService(
        id: event.id,
        title: event.title,
        description: event.description,
        category: event.category,
        price: event.price,
      );
      emit(WorkerServiceUpdated('Service updated successfully!'));
      final services = await serviceRepository.getMyServices();
      _services = services;
      emit(WorkerServicesLoaded(_services));
    } catch (e) {
      emit(WorkerServicesError('Failed to update service: $e'));
    }
  }

  Future<void> _onDelete(DeleteWorkerService event, Emitter emit) async {
    emit(WorkerServicesLoading());
    try {
      await serviceRepository.deleteService(event.id);
      emit(WorkerServiceDeleted('Service deleted.'));
      final services = await serviceRepository.getMyServices();
      _services = services;
      emit(WorkerServicesLoaded(_services));
    } catch (e) {
      emit(WorkerServicesError('Failed to delete service: $e'));
    }
  }
}

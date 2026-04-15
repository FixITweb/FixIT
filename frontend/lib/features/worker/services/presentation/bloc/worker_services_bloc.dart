import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_services_event.dart';
import 'worker_services_state.dart';

class WorkerServicesBloc extends Bloc<WorkerServicesEvent, WorkerServicesState> {
  List<WorkerServiceModel> _services = [];

  WorkerServicesBloc() : super(WorkerServicesInitial()) {
    on<LoadWorkerServices>((event, emit) async {
      emit(WorkerServicesLoading());
      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Mock data - replace with actual API call
        _services = [
          WorkerServiceModel(
            id: '1',
            title: 'Plumber - Sink Repair',
            category: 'Plumbing',
            price: 50.0,
            isActive: true,
            description: 'Professional sink repair service',
          ),
          WorkerServiceModel(
            id: '2',
            title: 'Emergency Plumbing',
            category: 'Plumbing',
            price: 75.0,
            isActive: true,
            description: '24/7 emergency plumbing service',
          ),
        ];
        
        emit(WorkerServicesLoaded(_services));
      } catch (e) {
        emit(WorkerServicesError(e.toString()));
      }
    });

    on<AddWorkerService>((event, emit) async {
      emit(WorkerServicesLoading());
      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 500));
        
        final newService = WorkerServiceModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: event.title,
          category: event.category,
          price: event.price,
          isActive: true,
          description: event.description,
        );
        
        _services.add(newService);
        emit(WorkerServiceAdded('Service added successfully!'));
        emit(WorkerServicesLoaded(_services));
      } catch (e) {
        emit(WorkerServicesError(e.toString()));
      }
    });

    on<ToggleServiceStatus>((event, emit) async {
      try {
        final serviceIndex = _services.indexWhere((s) => s.id == event.serviceId);
        if (serviceIndex != -1) {
          _services[serviceIndex] = _services[serviceIndex].copyWith(
            isActive: !_services[serviceIndex].isActive,
          );
          emit(WorkerServicesLoaded(_services));
        }
      } catch (e) {
        emit(WorkerServicesError(e.toString()));
      }
    });
  }
}
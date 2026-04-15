import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_service_event.dart';
import 'create_service_state.dart';

class CreateServiceBloc extends Bloc<CreateServiceEvent, CreateServiceState> {
  CreateServiceBloc() : super(CreateServiceInitial()) {
    on<CreateService>((event, emit) async {
      emit(CreateServiceLoading());
      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        
        // Here you would normally call your repository to create the service
        emit(CreateServiceSuccess('Service posted successfully!'));
      } catch (e) {
        emit(CreateServiceError(e.toString()));
      }
    });
  }
}
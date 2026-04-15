import 'package:flutter_bloc/flutter_bloc.dart';
import 'requests_event.dart';
import 'requests_state.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  RequestsBloc() : super(RequestsInitial()) {
    on<LoadRequests>((event, emit) async {
      emit(RequestsLoading());
      try {
        // Simulate API call
        await Future.delayed(const Duration(milliseconds: 500));
        
        // For now, return empty list - you can add mock data later
        emit(RequestsLoaded([]));
      } catch (e) {
        emit(RequestsError(e.toString()));
      }
    });
  }
}
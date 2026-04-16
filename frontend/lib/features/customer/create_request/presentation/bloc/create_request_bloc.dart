import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_request_event.dart';
import 'create_request_state.dart';
import '../../data/repositories/job_request_repository.dart';

class CreateRequestBloc extends Bloc<CreateRequestEvent, CreateRequestState> {
  final JobRequestRepository repository;

  CreateRequestBloc(this.repository) : super(CreateRequestInitial()) {
    on<SubmitRequest>((event, emit) async {
      emit(CreateRequestLoading());
      try {
        await repository.createJobRequest(
          title: event.title,
          description: event.description,
          category: event.category,
          budget: event.budget,
        );
        
        emit(CreateRequestSuccess(
          'Request posted successfully! You\'ll be notified when matching services are available.',
        ));
      } catch (e) {
        emit(CreateRequestError('Failed to post request: ${e.toString()}'));
      }
    });
  }
}

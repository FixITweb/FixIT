import 'package:flutter_bloc/flutter_bloc.dart';
import 'requests_event.dart';
import 'requests_state.dart';
import '../../../create_request/data/datasources/job_request_api.dart';
import '../../../create_request/data/repositories/job_request_repository.dart';
import '../../../../../core/network/api_client.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  final JobRequestRepository _repository;

  RequestsBloc()
      : _repository = JobRequestRepository(JobRequestApi(ApiClient())),
        super(RequestsInitial()) {
    on<LoadRequests>((event, emit) async {
      emit(RequestsLoading());
      try {
        final requests = await _repository.getJobRequests();
        emit(RequestsLoaded(requests));
      } catch (e) {
        emit(RequestsError(e.toString()));
      }
    });
  }
}

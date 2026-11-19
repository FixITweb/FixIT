import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_request_event.dart';
import 'create_request_state.dart';
import '../../data/repositories/job_request_repository.dart';
import '../../../../services/data/repositories/services_repository.dart';

class CreateRequestBloc extends Bloc<CreateRequestEvent, CreateRequestState> {
  final JobRequestRepository repository;
  final ServiceRepository serviceRepository;

  CreateRequestBloc({
    required this.repository,
    required this.serviceRepository,
  }) : super(CreateRequestInitial()) {
    on<LoadCategories>((event, emit) async {
      emit(CategoriesLoading());
      try {
        final categories = await serviceRepository.getCategories();
        final capitalized = categories.map((c) => _toTileCase(c)).toList();
        emit(CategoriesLoaded(
          capitalized.isEmpty ? defaultJobRequestCategories : capitalized,
        ));
      } catch (e) {
        emit(CategoriesLoadFailed(e.toString()));
      }
    });

    on<SubmitRequest>((event, emit) async {
      emit(CreateRequestLoading());
      try {
        await repository.createJobRequest(
          title: event.title,
          description: event.description,
          category: event.category,
          latitude: event.latitude,
          longitude: event.longitude,
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

  String _toTileCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

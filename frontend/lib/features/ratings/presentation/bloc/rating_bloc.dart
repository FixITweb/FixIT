import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/rating_repository.dart';
import 'rating_event.dart';
import 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final RatingRepository repository;

  RatingBloc(this.repository) : super(RatingInitial()) {
    on<SubmitRating>(_onSubmitRating);
    on<LoadWorkerRatings>(_onLoadWorkerRatings);
  }

  Future<void> _onSubmitRating(
    SubmitRating event,
    Emitter<RatingState> emit,
  ) async {
    emit(RatingLoading());
    try {
      final result = await repository.submitRating(
        workerId: event.workerId,
        rating: event.rating,
        review: event.review,
      );
      emit(RatingSuccess(message: result['message']));
    } catch (e) {
      emit(RatingError(message: e.toString()));
    }
  }

  Future<void> _onLoadWorkerRatings(
    LoadWorkerRatings event,
    Emitter<RatingState> emit,
  ) async {
    emit(RatingLoading());
    try {
      final ratings = await repository.getWorkerRatings(event.workerId);
      emit(RatingsLoaded(ratings: ratings));
    } catch (e) {
      emit(RatingError(message: e.toString()));
    }
  }
}

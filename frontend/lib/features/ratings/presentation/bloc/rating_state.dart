import '../../data/models/rating_model.dart';

abstract class RatingState {}

class RatingInitial extends RatingState {}

class RatingLoading extends RatingState {}

class RatingSuccess extends RatingState {
  final String message;

  RatingSuccess({required this.message});
}

class RatingError extends RatingState {
  final String message;

  RatingError({required this.message});
}

class RatingsLoaded extends RatingState {
  final List<RatingModel> ratings;

  RatingsLoaded({required this.ratings});
}

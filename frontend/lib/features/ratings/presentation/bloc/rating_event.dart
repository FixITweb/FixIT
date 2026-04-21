abstract class RatingEvent {}

class SubmitRating extends RatingEvent {
  final int workerId;
  final double rating;
  final String review;

  SubmitRating({
    required this.workerId,
    required this.rating,
    required this.review,
  });
}

class LoadWorkerRatings extends RatingEvent {
  final int workerId;

  LoadWorkerRatings(this.workerId);
}

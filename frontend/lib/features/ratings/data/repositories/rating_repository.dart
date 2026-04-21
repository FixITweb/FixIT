import '../datasources/rating_api.dart';
import '../models/rating_model.dart';

class RatingRepository {
  final RatingApi api;

  RatingRepository(this.api);

  Future<Map<String, dynamic>> submitRating({
    required int workerId,
    required double rating,
    required String review,
  }) async {
    return await api.submitRating(
      workerId: workerId,
      rating: rating,
      review: review,
    );
  }

  Future<List<RatingModel>> getWorkerRatings(int workerId) async {
    return await api.getWorkerRatings(workerId);
  }
}

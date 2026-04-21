import '../../../../core/network/api_client.dart';
import '../models/rating_model.dart';

class RatingApi {
  final ApiClient apiClient;

  RatingApi(this.apiClient);

  Future<Map<String, dynamic>> submitRating({
    required int workerId,
    required double rating,
    required String review,
  }) async {
    try {
      final response = await apiClient.post(
        'ratings/',
        data: {
          'worker_id': workerId,
          'rating': rating,
          'review': review,
        },
        requireAuth: true,
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to submit rating: $e');
    }
  }

  Future<List<RatingModel>> getWorkerRatings(int workerId) async {
    try {
      final response = await apiClient.get(
        'ratings/$workerId/',
        requireAuth: false,
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => RatingModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load ratings: $e');
    }
  }
}

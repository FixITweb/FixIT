import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

class RatingApi {
  final ApiClient client;

  RatingApi(this.client);

  Future<Map<String, dynamic>> createRating({
    required int workerId,
    required double rating,
    required String review,
  }) async {
    final res = await client.post(Endpoints.ratings, data: {
      'worker_id': workerId,
      'rating': rating,
      'review': review,
    });
    return res.data;
  }

  Future<List<dynamic>> getWorkerRatings(int workerId) async {
    final res = await client.get('${Endpoints.ratings}$workerId/');
    return res.data;
  }
}
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

class NotificationsApi {
  final ApiClient client;

  NotificationsApi(this.client);

  Future<List<dynamic>> getNotifications() async {
    try {
      final res = await client.get(Endpoints.notifications);
      if (res.data is List) {
        return res.data;
      } else if (res.data is Map && res.data['results'] is List) {
        // Handle paginated responses if necessary
        return res.data['results'];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await client.put(
        '${Endpoints.notifications}$notificationId/',
        data: {'is_read': true},
      );
    } catch (e) {
      rethrow;
    }
  }
}

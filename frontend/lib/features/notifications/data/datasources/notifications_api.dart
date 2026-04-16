import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

class NotificationsApi {
  final ApiClient client;

  NotificationsApi(this.client);

  Future<List<dynamic>> getNotifications() async {
    final res = await client.get(Endpoints.notifications);
    return res.data;
  }

  Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    final res = await client.put(
      '${Endpoints.notifications}$notificationId/',
      data: {'is_read': true},
    );
    return res.data;
  }
}

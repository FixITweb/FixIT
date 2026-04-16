import '../models/notification_model.dart';
import '../datasources/notifications_api.dart';

class NotificationsRepository {
  final NotificationsApi api;

  NotificationsRepository(this.api);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final data = await api.getNotifications();
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await api.markAsRead(notificationId);
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }
}

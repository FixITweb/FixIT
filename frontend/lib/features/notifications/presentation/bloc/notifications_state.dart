import '../../data/models/notification_model.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;

  NotificationsLoaded(this.notifications);

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationsError extends NotificationsState {
  final String message;

  NotificationsError(this.message);
}

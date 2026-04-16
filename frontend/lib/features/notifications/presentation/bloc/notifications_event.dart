abstract class NotificationsEvent {}

class LoadNotifications extends NotificationsEvent {}

class MarkAsRead extends NotificationsEvent {
  final int notificationId;

  MarkAsRead(this.notificationId);
}

class RefreshNotifications extends NotificationsEvent {}

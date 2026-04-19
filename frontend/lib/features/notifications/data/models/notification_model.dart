class NotificationModel {
  final int id;
  final String message;
  final int? serviceId;
  final bool isRead;
  final DateTime createdAt;
  final String? user;

  NotificationModel({
    required this.id,
    required this.message,
    this.serviceId,
    required this.isRead,
    required this.createdAt,
    this.user,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      user: json['user'],
      // backend may return service_id or not — handle both
      serviceId: json['service_id'] ?? json['service'],
      isRead: json['is_read'] ?? false,
      // backend notifications_list doesn't return created_at — use now as fallback
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );

  }
}

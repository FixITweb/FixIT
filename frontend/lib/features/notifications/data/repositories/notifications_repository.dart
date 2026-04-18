import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../datasources/notifications_api.dart';

class NotificationsRepository {
  final NotificationsApi api;
  static const String _cacheKey = 'cached_notifications';

  NotificationsRepository(this.api);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      // Try to load from cache first for instant UI
      final cachedData = await _loadFromCache();
      
      // Fetch from API
      final data = await api.getNotifications();
      final notifications = data.map((e) => NotificationModel.fromJson(e)).toList();
      
      // Update cache
      await _saveToCache(notifications);
      
      return notifications;
    } catch (e) {
      // If network fails, return cached data if available
      final cachedData = await _loadFromCache();
      if (cachedData.isNotEmpty) {
        return cachedData;
      }
      throw Exception('Failed to load notifications: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await api.markAsRead(notificationId);
      
      // Update local cache to reflect current state
      final cached = await _loadFromCache();
      final updated = cached.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      await _saveToCache(updated);
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  Future<void> _saveToCache(List<NotificationModel> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      notifications.map((n) => {
        'id': n.id,
        'title': n.title,
        'description': n.description,
        'is_read': n.isRead,
        'created_at': n.createdAt.toIso8601String(),
      }).toList(),
    );
    await prefs.setString(_cacheKey, encoded);
  }

  Future<List<NotificationModel>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(_cacheKey);
      if (encoded == null) return [];
      
      final List<dynamic> decoded = jsonDecode(encoded);
      return decoded.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}

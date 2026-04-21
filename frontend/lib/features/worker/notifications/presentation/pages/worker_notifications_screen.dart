import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../dashboard/presentation/widgets/worker_bottom_nav.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/notifications/data/datasources/notifications_api.dart';
import 'package:frontend/features/notifications/data/repositories/notifications_repository.dart';
import 'package:frontend/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:frontend/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:frontend/features/notifications/presentation/bloc/notifications_state.dart';

class WorkerNotificationsScreen extends StatelessWidget {
  const WorkerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsBloc(
        NotificationsRepository(NotificationsApi(ApiClient())),
      )..add(LoadNotifications()),
      child: const WorkerNotificationsView(),
    );
  }
}

class WorkerNotificationsView extends StatefulWidget {
  const WorkerNotificationsView({super.key});

  @override
  State<WorkerNotificationsView> createState() => _WorkerNotificationsViewState();
}

class _WorkerNotificationsViewState extends State<WorkerNotificationsView> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<NotificationsBloc>().add(LoadNotifications()),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<NotificationsBloc>().add(LoadNotifications()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }

            // Count unread notifications
            final unreadCount = state.notifications.where((n) => !n.isRead).length;

            // Filter notifications
            final filteredNotifications = _selectedFilter == 'all'
                ? state.notifications
                : _selectedFilter == 'unread'
                    ? state.notifications.where((n) => !n.isRead).toList()
                    : state.notifications.where((n) => n.isRead).toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationsBloc>().add(LoadNotifications());
              },
              child: Column(
                children: [
                  // Filter and action bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _NotificationFilterChip(
                                  label: 'All',
                                  isSelected: _selectedFilter == 'all',
                                  onTap: () => setState(() => _selectedFilter = 'all'),
                                ),
                                const SizedBox(width: 8),
                                _NotificationFilterChip(
                                  label: 'Unread ($unreadCount)',
                                  isSelected: _selectedFilter == 'unread',
                                  onTap: () => setState(() => _selectedFilter = 'unread'),
                                ),
                                const SizedBox(width: 8),
                                _NotificationFilterChip(
                                  label: 'Read',
                                  isSelected: _selectedFilter == 'read',
                                  onTap: () => setState(() => _selectedFilter = 'read'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (unreadCount > 0)
                          IconButton(
                            icon: const Icon(Icons.done_all, size: 20),
                            tooltip: 'Mark all as read',
                            onPressed: () {
                              for (var notification in state.notifications.where((n) => !n.isRead)) {
                                context.read<NotificationsBloc>().add(MarkAsRead(notification.id));
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filteredNotifications.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'No $_selectedFilter notifications',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredNotifications.length,
                            itemBuilder: (context, index) {
                              final notification = filteredNotifications[index];
                              
                              IconData icon = Icons.notifications;
                              Color iconColor = const Color(0xFF14B8A6);
                              
                              final msgLower = notification.message.toLowerCase();
                              if (msgLower.contains('booking request')) {
                                icon = Icons.assignment_turned_in;
                                iconColor = Colors.orange;
                              } else if (msgLower.contains('matched') || msgLower.contains('available')) {
                                icon = Icons.handshake;
                                iconColor = Colors.blue;
                              } else if (msgLower.contains('completed')) {
                                icon = Icons.done_all;
                                iconColor = Colors.green;
                              }

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: notification.isRead ? 0 : 2,
                                color: notification.isRead ? Colors.white : const Color(0xFF14B8A6).withOpacity(0.05),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: iconColor.withOpacity(0.1),
                                    child: Icon(icon, color: iconColor),
                                  ),
                                  title: Text(
                                    notification.message,
                                    style: TextStyle(
                                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (notification.user != null && notification.user!.isNotEmpty)
                                        Text("From: ${notification.user}", style: const TextStyle(fontWeight: FontWeight.w500)),
                                      Text(_formatDate(notification.createdAt), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    ],
                                  ),
                                  trailing: notification.isRead
                                      ? null
                                      : const Icon(Icons.circle, size: 8, color: Color(0xFF14B8A6)),
                                  onTap: () {
                                    if (!notification.isRead) {
                                      context.read<NotificationsBloc>().add(
                                            MarkAsRead(notification.id),
                                          );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
      bottomNavigationBar: const WorkerBottomNav(currentIndex: 3),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}


class _NotificationFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NotificationFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF14B8A6) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF14B8A6) : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../../../customer/home/presentation/widgets/bottom_nav.dart';
import '../../../../core/network/api_client.dart';
import '../../../notifications/data/datasources/notifications_api.dart';
import '../../../notifications/data/repositories/notifications_repository.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsBloc(
        NotificationsRepository(NotificationsApi(ApiClient())),
      )..add(LoadNotifications()),
      child: const NotificationsView(),
    );
  }
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
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
                    SizedBox(height: 8),
                    Text(
                      'You\'ll be notified when services become available',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationsBloc>().add(LoadNotifications());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  
                  // Determine icon and color based on notification type
                  IconData icon = Icons.notifications;
                  Color iconColor = Colors.teal;
                  
                  if (notification.message.contains('available') || 
                      notification.message.contains('now offering')) {
                    icon = Icons.new_releases;
                    iconColor = Colors.green;
                  } else if (notification.message.contains('accepted')) {
                    icon = Icons.check_circle;
                    iconColor = Colors.blue;
                  } else if (notification.message.contains('completed')) {
                    icon = Icons.done_all;
                    iconColor = Colors.purple;
                  } else if (notification.message.contains('booking')) {
                    icon = Icons.calendar_today;
                    iconColor = Colors.orange;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: notification.isRead ? 0 : 2,
                    color: notification.isRead ? null : Colors.teal.withOpacity(0.05),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: iconColor.withOpacity(0.2),
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
                          : const Icon(Icons.circle, size: 8, color: Colors.teal),
                      onTap: () {
                        if (!notification.isRead) {
                          context.read<NotificationsBloc>().add(
                                MarkAsRead(notification.id),
                              );
                        }
                        // Navigate to service if available
                        if (notification.serviceId != null) {
                          Navigator.pushNamed(
                            context,
                            '/service-detail',
                            arguments: notification.serviceId.toString(),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
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

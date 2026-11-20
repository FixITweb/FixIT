import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
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
            onPressed: () =>
                context.read<NotificationsBloc>().add(LoadNotifications()),
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
                    onPressed: () => context
                        .read<NotificationsBloc>()
                        .add(LoadNotifications()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 80,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'ll be notified when services become available',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  final isDark = theme.brightness == Brightness.dark;

                  // Determine icon and color based on notification type
                  IconData icon = Icons.notifications;
                  Color iconColor = colorScheme.primary;

                  if (notification.message.contains('available') ||
                      notification.message.contains('now offering')) {
                    icon = Icons.new_releases_rounded;
                    iconColor = isDark ? const Color(0xFF34D399) : Colors.green;
                  } else if (notification.message.contains('accepted')) {
                    icon = Icons.check_circle_rounded;
                    iconColor = isDark ? const Color(0xFF60A5FA) : Colors.blue;
                  } else if (notification.message.contains('completed')) {
                    icon = Icons.done_all_rounded;
                    iconColor = isDark ? const Color(0xFFA78BFA) : Colors.purple;
                  } else if (notification.message.contains('booking')) {
                    icon = Icons.calendar_today_rounded;
                    iconColor = isDark ? const Color(0xFFFBBF24) : Colors.orange;
                  }

                  // Always use colorScheme — works consistently in light and dark
                  final cardBg = notification.isRead
                      ? colorScheme.surfaceContainerLow
                      : colorScheme.surfaceContainer;

                  final cardBorderColor = notification.isRead
                      ? colorScheme.outlineVariant.withOpacity(0.5)
                      : colorScheme.primary.withOpacity(isDark ? 0.4 : 0.25);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: cardBorderColor,
                        width: notification.isRead ? 1 : 1.2,
                      ),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                    notification.isRead ? 0.02 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
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
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: iconColor.withOpacity(isDark ? 0.16 : 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: iconColor, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.message,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: notification.isRead
                                            ? FontWeight.w500
                                            : FontWeight.w700,
                                        color: colorScheme.onSurface,
                                        height: 1.3,
                                      ),
                                    ),
                                    if (notification.user != null &&
                                        notification.user!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        "From: ${notification.user}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Text(
                                      _formatDate(notification.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: isDark
                                            ? colorScheme.onSurfaceVariant.withOpacity(0.7)
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  margin: const EdgeInsets.only(top: 4, left: 8),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
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

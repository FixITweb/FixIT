import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  State<WorkerNotificationsView> createState() =>
      _WorkerNotificationsViewState();
}

class _WorkerNotificationsViewState extends State<WorkerNotificationsView> {
  String _selectedFilter = 'all';

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
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none,
                        size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }

            // Count unread notifications
            final unreadCount =
                state.notifications.where((n) => !n.isRead).length;

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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                NotificationFilterChip(
                                  label: 'All',
                                  isSelected: _selectedFilter == 'all',
                                  onTap: () =>
                                      setState(() => _selectedFilter = 'all'),
                                ),
                                const SizedBox(width: 8),
                                NotificationFilterChip(
                                  label: 'Unread ($unreadCount)',
                                  isSelected: _selectedFilter == 'unread',
                                  onTap: () => setState(
                                      () => _selectedFilter = 'unread'),
                                ),
                                const SizedBox(width: 8),
                                NotificationFilterChip(
                                  label: 'Read',
                                  isSelected: _selectedFilter == 'read',
                                  onTap: () =>
                                      setState(() => _selectedFilter = 'read'),
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
                              for (var notification in state.notifications
                                  .where((n) => !n.isRead)) {
                                context
                                    .read<NotificationsBloc>()
                                    .add(MarkAsRead(notification.id));
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
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No $_selectedFilter notifications',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: filteredNotifications.length,
                            itemBuilder: (context, index) {
                              final notification = filteredNotifications[index];
                              final theme = Theme.of(context);
                              final colorScheme = theme.colorScheme;
                              final isDark = theme.brightness == Brightness.dark;

                              IconData icon = Icons.notifications;
                              Color iconColor = colorScheme.primary;

                              final msgLower =
                                  notification.message.toLowerCase();
                              if (msgLower.contains('booking request')) {
                                icon = Icons.assignment_turned_in_rounded;
                                iconColor = isDark
                                    ? const Color(0xFFFBBF24)
                                    : const Color(0xFFEA580C);
                              } else if (msgLower.contains('matched') ||
                                  msgLower.contains('available')) {
                                icon = Icons.handshake_rounded;
                                iconColor = isDark
                                    ? const Color(0xFF60A5FA)
                                    : const Color(0xFF2563EB);
                              } else if (msgLower.contains('completed')) {
                                icon = Icons.done_all_rounded;
                                iconColor = isDark
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF059669);
                              }

                              // Always use colorScheme — works correctly for both light and dark
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
                                                notification.isRead ? 0.03 : 0.05),
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
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
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

class NotificationFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NotificationFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = isSelected
        ? colorScheme.primary
        : (isDark ? colorScheme.surfaceContainer : Colors.white);

    final border = isSelected
        ? colorScheme.primary
        : (isDark
            ? colorScheme.outlineVariant.withOpacity(0.5)
            : colorScheme.outlineVariant);

    final textColor = isSelected
        ? colorScheme.onPrimary
        : (isDark ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1),
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

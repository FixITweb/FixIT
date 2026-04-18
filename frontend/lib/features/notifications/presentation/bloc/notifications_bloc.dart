import 'package:flutter_bloc/flutter_bloc.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';
import '../../data/repositories/notifications_repository.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository repository;

  NotificationsBloc(this.repository) : super(NotificationsInitial()) {
    on<LoadNotifications>((event, emit) async {
      emit(NotificationsLoading());
      try {
        final notifications = await repository.getNotifications();
        emit(NotificationsLoaded(notifications));
      } catch (e) {
        emit(NotificationsError('Failed to load notifications: ${e.toString()}'));
      }
    });

    on<MarkAsRead>((event, emit) async {
      final currentState = state;
      if (currentState is NotificationsLoaded) {
        // Optimistic update
        final updatedNotifications = currentState.notifications.map((n) {
          if (n.id == event.notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
        
        emit(NotificationsLoaded(updatedNotifications));

        try {
          await repository.markAsRead(event.notificationId);
          // Optional: We could reload to be extra sure, but optimistic is enough
          // add(LoadNotifications()); 
        } catch (e) {
          // Revert on failure
          emit(NotificationsLoaded(currentState.notifications));
          emit(NotificationsError('Failed to mark as read: ${e.toString()}'));
        }
      }
    });

    on<RefreshNotifications>((event, emit) async {
      add(LoadNotifications());
    });
  }
}

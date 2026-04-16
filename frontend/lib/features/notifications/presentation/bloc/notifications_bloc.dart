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
      try {
        await repository.markAsRead(event.notificationId);
        // Reload notifications after marking as read
        add(LoadNotifications());
      } catch (e) {
        emit(NotificationsError('Failed to mark as read: ${e.toString()}'));
      }
    });

    on<RefreshNotifications>((event, emit) async {
      add(LoadNotifications());
    });
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/notification_model.dart';
import '../../repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository})
    : super(NotificationInitial()) {
    on<GetNotificationsRequested>(_onGetNotificationsRequested);
    on<MarkNotificationReadRequested>(_onMarkNotificationReadRequested);
    on<RegisterDeviceTokenRequested>(_onRegisterDeviceTokenRequested);
  }

  Future<void> _onGetNotificationsRequested(
    GetNotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await notificationRepository.getNotifications(
        limit: event.limit,
      );
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkNotificationReadRequested(
    MarkNotificationReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentNotifications = (state as NotificationLoaded).notifications;
      final updatedNotifications = currentNotifications.map((n) {
        if (n.id == event.notificationId) {
          return NotificationModel(
            id: n.id,
            title: n.title,
            message: n.message,
            notificationType: n.notificationType,
            orderId: n.orderId,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      emit(NotificationLoaded(updatedNotifications));
    }

    try {
      await notificationRepository.markAsRead(event.notificationId);
    } catch (e) {
      // Ignore or handle error
    }
  }

  Future<void> _onRegisterDeviceTokenRequested(
    RegisterDeviceTokenRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      print('📢 NotificationBloc: Registering token...');
      await notificationRepository.registerDeviceToken(event.token);
    } catch (e) {
      print('⚠️ NotificationBloc Error: $e');
    }
  }
}

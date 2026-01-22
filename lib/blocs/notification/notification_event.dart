import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class GetNotificationsRequested extends NotificationEvent {
  final int limit;

  const GetNotificationsRequested({this.limit = 50});

  @override
  List<Object> get props => [limit];
}

class MarkNotificationReadRequested extends NotificationEvent {
  final int notificationId;

  const MarkNotificationReadRequested(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class RegisterDeviceTokenRequested extends NotificationEvent {
  final String token;

  const RegisterDeviceTokenRequested(this.token);

  @override
  List<Object> get props => [token];
}

part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentSuccess extends AuthState {
  final String phoneNumber;
  final Map<String, dynamic> data;

  const OtpSentSuccess({required this.phoneNumber, required this.data});

  @override
  List<Object> get props => [phoneNumber, data];
}

class AuthUnregistered extends AuthState {
  final DeliveryBoyModel deliveryBoy;

  const AuthUnregistered(this.deliveryBoy);

  @override
  List<Object> get props => [deliveryBoy];
}

class AuthAuthenticated extends AuthState {
  final DeliveryBoyModel deliveryBoy;

  const AuthAuthenticated(this.deliveryBoy);

  @override
  List<Object> get props => [deliveryBoy];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}
